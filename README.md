# Routing with Azure Firewall plus forced tunneling (Under construction)

## Description

Routing in networking can be defined a process of selecting path across one or more networks which data can be transferred from a source to a destination. Routing appliances use routing tables to make decisions about how to route packets along network paths. Routing tables record the path to get to every network.

In order to optimize your traffic delivery between your Azure resources and clients on the Internet or on-premises location(s), Azure routing has a variety of solutions on how to choose the best route, and the process is quite different from what we're accustomed to when it comes to the traditional networking.

In this lab, we'll be dissecting the routing process on Azure. We'll talk about the *system routes, user definer routes, BGP routes* and the routing process implicating all these routes types. Also,we'll be demonstrating how routing through an Azure Firewall affects the routing process. Finally, we'll see how the Forced tunneling which is one of the best network features is configured effectively.

## Lab architecture

![RoutingWithFW](https://github.com/Tchimwa/Routing-with-Azure-Firewall-plus-forced-tunneling/blob/main/images/Labtime3_Architecture.png)

This lab consists of 2 different environments which are On-premises and Azure.

From the On-premises side, we have:

- a branch represented by the vnet: **VNET-BR01** - **172.16.10.0/24**
- Another branch: **VNET-BR02** - **172.16.20.0/24**
- VPN appliance Cisco CSR1000v for VNET-BRO1: **BR-01**
- VPN appliance Cisco CSR1000v for VNET-BRO2:**BR-02**
- BGP attributes for BR-01: **ASN:65100, Peer-IP:10.10.10.10**
- BGP attributes for BR-02: **ASN:65200, Peer-IP: 20.20.20.2.**

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

Both vnets are connected using a global peering connection **East-to-CENTRAL**.

## Lab requirements

### Routing policies

Those are the routing requirements to be implemented on the architecture during the lab session:

- Communication from spokes to any destination goes through the Firewall(s)
- Communication between the subnets within any Hub goes through the Firewall
- Hub to Hub will go through both firewalls
- Hub to On-premises goes through firewall

### Force tunneling

- East-US spokes and Hub will go through **VPN-GW-EAST** and **BR-02** with a redundancy on **BR-01** in case of failure
- Central-US spokes and Hub will go through **VPN-GW-CENTRAL** and **BR-01** with a redundancy on **BR-02** in case of failure


