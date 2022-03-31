# Routing with Azure Firewall plus forced tunneling (Under construction)

## Description

Routing in networking can be defined a process of selecting path across one or more networks which data can be transferred from a source to a destination. Routing appliances use routing tables to make decisions about how to route packets along network paths. Routing tables record the path to get to every network.

In order to optimize your traffic delivery between your Azure resources and clients on the Internet or on-premises location(s), Azure routing has a variety of solutions on how to choose the best route, and the process is quite different from what we're accustomed to when it comes to the traditional networking.

In this lab, we'll be dissecting the routing process on Azure. We'll talk about the *system routes, user definer routes, BGP routes* and the routing process implicating all these routes types. Also,we'll be demonstrating how routing through an Azure Firewall affects the routing process. Finally, we'll see how the Forced tunneling which is one of the best network features is configured effectively.

## Lab architecture

![RoutingWithFW](https://github.com/Tchimwa/Routing-with-Azure-Firewall-plus-forced-tunneling/blob/main/images/Labtime3_Architecture.png)

This lab consists of 2 different environments: On-premises and Azure.
> ***Note: For this lab, I chose to use **eastus** and **centralus**, so most of the resources will be named after those two regions. Feel free to make the changes on the variable "Prefix" on variables.tf  located at the root. Just make sure that the regions you choose to use are "zone redundant" for the public IPs.***

AZ Regions: <https://docs.microsoft.com/en-us/azure/availability-zones/az-region#azure-regions-with-availability-zones>

From the On-premises side, we have:

- First branch represented by the vnet: **VNET-BR01** - **172.16.10.0/24**
- Second branch: **VNET-BR02** - **172.16.20.0/24**
- VPN appliance Cisco CSR1000v for VNET-BR01: **BR-01**
- VPN appliance Cisco CSR1000v for VNET-BR02: **BR-02**
- BGP attributes for BR-01: **ASN:65100 - Peer-IP:10.10.10.10**
- BGP attributes for BR-02: **ASN:65200 - Peer-IP: 20.20.20.2.**

From Azure:

- East Hub Vnet: **VNET-EAST** - **10.200.0.0/16**
- East Hub VPN Gateway: **VPN-GW-EAST**
- East Hub Azure Firewall : **FW-EAST**
- BGP attributes for VPN-GW-EAST: **ASN:65020**
- Two spokes: **VNET-EAST-01 - 10.210.0.0/16** and **VNET-EAST-02 - 10.220.0.0/16**.

- CENTRAL Hub Vnet: **VNET-CENTRAL** - **10.200.0.0/16**
- CENTRAL Hub VPN Gateway: **VPN-GW-CENTRAL**
- CENTRAL Hub Azure Firewall : **FW-CENTRAL**
- BGP attributes for VPN-GW-CENTRAL: **ASN:65010**
- Two spokes: **VNET-CENTRAL-01 - 10.110.0.0/16** and **VNET-CENTRAL-02 - 10.120.0.0/16**.

Both vnets are connected using a global peering connection **East-to-Central**.

## Lab requirements

Beside of having an Azure Subscription, the tools below will be needed only if you choose to use VS Code from your computer and not Azure Cloud Shell:

1. VS Code with Terraform and Shell extensions installed if you are looking to use Visual Studio code
2. Install the PS Tools on the Windows VM
3. GIT

For learning purposes, I chose to deploy the on-premises environment using AzCLI+Bash Script and that will be the file "***onprem-env.sh***". The cloud environment was built using Terraform. Deploying the architecture will be done following the steps listed below while running these commands from a Bash terminal:

- Cloning the repo : ***git clone "https://github.com/Tchimwa/Routing-with-Azure-Firewall-plus-forced-tunneling.git"***
- ***cd ./Routing-with-Azure-Firewall-plus-forced-tunneling***
- ***terraform init***
- ***terraform plan*** - Here you will be asked to enter your alias. Feel free to use your initials or your alias
- ***terraform apply***

### Routing tasks to complete

Those are the routing requirements to be implemented on the architecture during the lab session:

- Communication from spokes to any destination goes through the Firewall(s)
- Communication between the subnets within any Hub goes through the Firewall
- Hub to Hub will go through both firewalls
- Hub to On-premises goes through firewall

### Force tunneling

- East-US spokes and Hub will go through **VPN-GW-EAST** and **BR-02** with a redundancy on **BR-01** in case of failure
- Central-US spokes and Hub will go through **VPN-GW-CENTRAL** and **BR-01** with a redundancy on **BR-02** in case of failure

## Configuration

> ***Note:*** Make sure you replace the resource group in the commands by yours. Mine, as you see is "tcs-azcloud-rg".

### VPN connections

#### Creation of the local Network Gateways

az network local-gateway create --gateway-ip-address ***br-01-pip*** --name east-br01-lng --resource-group tcs-azcloud-rg --asn 65100 --bgp-peering-address 10.10.10.10 --location eastus
az network local-gateway create --gateway-ip-address ***br-02-pip*** --name east-br02-lng --resource-group tcs-azcloud-rg  --asn 65200 --bgp-peering-address 20.20.20.20 --location eastus
az network local-gateway create --gateway-ip-address ***br-01-pip*** --name central-br01-lng --resource-group tcs-azcloud-rg --asn 65100 --bgp-peering-address 10.10.10.10 --location centralus
az network local-gateway create --gateway-ip-address ***br-02-pip*** --name central-br02-lng --resource-group tcs-azcloud-rg  --asn 65200 --bgp-peering-address 20.20.20.20 --location centralus

#### Creation of the IPSec VPN connections

az network vpn-connection create --name east-to-br01 --resource-group tcs-azcloud-rg --vnet-gateway1 vpn-gw-eastus --location eastus --local-gateway2 east-br01-lng --enable-bgp --shared-key Networking2022#
az network vpn-connection create --name east-to-br02 --resource-group tcs-azcloud-rg --vnet-gateway1 vpn-gw-eastus --location eastus --local-gateway2 east-br02-lng --enable-bgp --shared-key Networking2022#
az network vpn-connection create --name central-to-br01 --resource-group tcs-azcloud-rg --vnet-gateway1 vpn-gw-centralus --location centralus --local-gateway2 central-br01-lng --enable-bgp --shared-key Networking2022#
az network vpn-connection create --name central-to-br02 --resource-group tcs-azcloud-rg --vnet-gateway1 vpn-gw-centralus --location centralus --local-gateway2 central-br02-lng --enable-bgp --shared-key Networking2022#

#### Gathering data from the VPN Gateway to set up the tunnels

az network public-ip show --resource-group tcs-azcloud-rg --name vpngw-eastus-pip --query "{address: ipAddress}"
az network public-ip show --resource-group tcs-azcloud-rg --name vpngw-centralus-pip --query "{address: ipAddress}"
az network vnet-gateway list  --resource-group tcs-azcloud-rg --query [].[name,bgpSettings.asn,bgpSettings.bgpPeeringAddress] -o table

#### Setting up the VPN on the routers BR-01 and BR-02

Using the credentials below, log in on the VMs ***BR-01*** and ***BR-02*** using Bastion, and follow the steps:

- Enter " ***config t***
- Copy the commands below, paste them on Notepad replace the parameters ***vpngw-eastus-pip*** and ***vpngw-centralus-pip*** with their respective values.
  - **BR-01**

```typescript
ip route 172.10.2.0 255.255.255.0 172.10.1.1
crypto ikev2 proposal AzIkev2Proposal
 encryption aes-cbc-256
 integrity sha1
 group 2
 exit
crypto ikev2 policy AzIkev2Pol 
 match address local 172.10.0.4
 proposal AzIkev2Proposal
 exit     
crypto ikev2 keyring AzToOnPremKeyring
 peer ***vpngw-eastus-pip***
  address ***vpngw-eastus-pip***
  pre-shared-key Networking2022#
  exit
 peer ***vpngw-centralus-pip***
  address ***vpngw-centralus-pip***
  pre-shared-key Networking2022#
  exit
 exit
crypto ikev2 profile AzIkev2Prof
 match address local 172.10.0.4
 match identity remote address ***vpngw-eastus-pip*** 255.255.255.255 
 match identity remote address ***vpngw-centralus-pip*** 255.255.255.255 
 authentication remote pre-share
 authentication local pre-share
 keyring local AzToOnPremKeyring
 lifetime 28800
 dpd 10 5 on-demand
 exit
crypto ipsec transform-set Az-xformSet esp-gcm 256 
 mode tunnel
 exit
crypto ipsec profile Az-IPSec-Profile
 set transform-set Az-xformSet 
 set ikev2-profile AzIkev2Prof
 exit
interface Loopback11
 ip address 10.10.10.10 255.255.255.255
 no shut
 exit
interface Tunnel11
 ip address 11.11.11.11 255.255.255.255
 no shut
 ip tcp adjust-mss 1350
 tunnel source 172.10.0.4
 tunnel mode ipsec ipv4
 tunnel destination ***vpngw-eastus-pip***
 tunnel protection ipsec profile Az-IPSec-Profile
 exit
interface Tunnel10
 ip address 12.12.12.12 255.255.255.255
 no shut
 ip tcp adjust-mss 1350
 tunnel source 172.10.0.4
 tunnel mode ipsec ipv4
 tunnel destination ***vpngw-centralus-pip***
 tunnel protection ipsec profile Az-IPSec-Profile
 exit
ip route 10.200.0.254 255.255.255.255 Tunnel11
ip route 10.100.0.254 255.255.255.255 Tunnel10
router bgp 65100
 bgp router-id 10.10.10.10
 bgp log-neighbor-changes
 neighbor 10.200.0.254 remote-as 65020
 neighbor 10.200.0.254 ebgp-multihop 255
 neighbor 10.200.0.254 update-source Loopback11
 neighbor 10.100.0.254 remote-as 65010
 neighbor 10.100.0.254 ebgp-multihop 255
 neighbor 10.100.0.254 update-source Loopback11
 address-family ipv4
  network 172.10.2.0 mask 255.255.255.0
  neighbor 10.200.0.254 activate
  neighbor 10.100.0.254 activate
  maximum-paths 2
  exit-address-family
 exit
```

- **BR-02**

```typescript
ip route 172.20.2.0 255.255.255.0 172.20.1.1
crypto ikev2 proposal AzIkev2Proposal
 encryption aes-cbc-256
 integrity sha1
 group 2
 exit
crypto ikev2 policy AzIkev2Pol 
 match address local 172.20.0.4
 proposal AzIkev2Proposal
 exit     
crypto ikev2 keyring AzToOnPremKeyring
 peer ***vpngw-eastus-pip***
  address ***vpngw-eastus-pip***
  pre-shared-key Networking2022#
  exit
 peer ***vpngw-centralus-pip***
  address ***vpngw-centralus-pip***
  pre-shared-key Networking2022#
  exit
 exit
crypto ikev2 profile AzIkev2Prof
 match address local 172.20.0.4
 match identity remote address ***vpngw-eastus-pip*** 255.255.255.255 
 match identity remote address ***vpngw-centralus-pip*** 255.255.255.255 
 authentication remote pre-share
 authentication local pre-share
 keyring local AzToOnPremKeyring
 lifetime 28800
 dpd 10 5 on-demand
 exit
crypto ipsec transform-set Az-xformSet esp-gcm 256 
 mode tunnel
 exit
crypto ipsec profile Az-IPSec-Profile
 set transform-set Az-xformSet
 set ikev2-profile AzIkev2Prof
 exit
interface Loopback11
 ip address 20.20.20.20 255.255.255.255
 no shut
 exit
interface Tunnel1
 ip address 21.21.21.21 255.255.255.255
 no shut
 ip tcp adjust-mss 1350
 tunnel source 172.20.0.4
 tunnel mode ipsec ipv4
 tunnel destination ***vpngw-eastus-pip***
 tunnel protection ipsec profile Az-IPSec-Profile
 exit
interface Tunnel2
 ip address 22.22.22.22 255.255.255.255
 no shut
 ip tcp adjust-mss 1350
 tunnel source 172.20.0.4
 tunnel mode ipsec ipv4
 tunnel destination ***vpngw-centralus-pip***
 tunnel protection ipsec profile Az-IPSec-Profile
 exit
ip route 10.200.0.254 255.255.255.255 Tunnel1
ip route 10.100.0.254 255.255.255.255 Tunnel2
router bgp 65200
 bgp router-id 20.20.20.20
 bgp log-neighbor-changes
 neighbor 10.200.0.254 remote-as 65020
 neighbor 10.200.0.254 ebgp-multihop 255
 neighbor 10.200.0.254 update-source Loopback11
 neighbor 10.100.0.254 remote-as 65010
 neighbor 10.100.0.254 ebgp-multihop 255
 neighbor 10.100.0.254 update-source Loopback11
 address-family ipv4
  network 172.20.2.0 mask 255.255.255.0
  neighbor 10.200.0.254 activate
  neighbor 10.100.0.254 activate
  maximum-paths 2
  exit-address-family
 exit
```

- Once the values have been replaced, copy the commands and paste them in the VM's terminal.

#### Connections Status and route tables Check

- Connections Status

```azurecli-interactive
az network vpn-connection show -n east-to-br01 -g tcs-azcloud-rg --query "{status: connectionStatus}"
az network vpn-connection show -n east-to-br02 -g tcs-azcloud-rg --query "{status: connectionStatus}"
az network vpn-connection show -n central-to-br01 -g tcs-azcloud-rg --query "{status: connectionStatus}"
az network vpn-connection show -n central-to-br02 -g tcs-azcloud-rg --query "{status: connectionStatus}"
```

- Routes tables

```azurecli-interactive
az network vnet-gateway list-learned-routes --resource-group tcs-azcloud-rg --name vpn-gw-eastus -o table
az network vnet-gateway list-learned-routes --resource-group tcs-azcloud-rg --name vpn-gw-centralus -o table

az network vnet-gateway list-advertised-routes --resource-group tcs-azcloud-rg --name vpn-gw-eastus --peer 10.10.10.10 -o table
az network vnet-gateway list-advertised-routes --resource-group tcs-azcloud-rg --name vpn-gw-centralus --peer 10.10.10.10 -o table

az network vnet-gateway list-advertised-routes --resource-group tcs-azcloud-rg --name vpn-gw-eastus --peer 20.20.20.20 -o table
az network vnet-gateway list-advertised-routes --resource-group tcs-azcloud-rg --name vpn-gw-centralus --peer 20.20.20.20 -o table
```

Sample results:

![InitialRoutes](https://github.com/Tchimwa/Routing-with-Azure-Firewall-plus-forced-tunneling/blob/main/images/InitialConnectionCheck.png)

### Tasks to complete

