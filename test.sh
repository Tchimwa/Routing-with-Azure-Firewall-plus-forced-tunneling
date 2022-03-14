#!/bin/bash
#This has to be ran after deploying the cloud environment. 
#There are some values used here that will be coming from the cloud resources like the BGP values for the IPsec connections

printf "=========== On-premises environment Deployment==========\n" | sed -e "s/On-premises environment Deployment/ \x1b[36mOn-premises environment Deployment\x1b[0m/g"
printf "******** Resource Group ********\n" | sed -e "s/Resource Group/ \x1b[32mResource Group\x1b[0m/g"
sleep 5

az group create --name branch-rg --location eastus --query '{Name:name,Location:location}' -o table
sleep 5

printf "\n******** Network Security Group for the routers ********\n" | sed -e "s/Network Security Group for the routers/ \x1b[32mNetwork Security Group for the routers\x1b[0m/g"
sleep 5

nsg01_name=$(az network nsg create --name br-01-nsg --resource-group branch-rg --location eastus --query NewNSG.name)
nsg02_name=$(az network nsg create --name br-02-nsg --resource-group branch-rg --location eastus2 --query NewNSG.name)

printf "BR-01 router's network security group is \e[33m $nsg01_name \e[0m." 
printf "BR-02 router's network security group is \e[33m $nsg02_name \e[0m.\n" 

az network nsg rule create --name Allow-SSH --nsg-name br-01-nsg --resource-group branch-rg --access Allow --description "SSH Ingress Traffic Allowed" --priority 110 --protocol TCP --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22 --query '{Name:name,Source:sourceAddressPrefix,PORT:destinationPortRange,Type:direction,Priority:priority}' --output table
az network nsg rule create --name Allow-SSH --nsg-name br-02-nsg --resource-group branch-rg --access Allow --description "SSH Ingress Traffic Allowed" --priority 110 --protocol TCP --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22 --output none

printf "\n******** First branch virtual Network ********\n" | sed -e "s/First branch virtual Network/ \x1b[32mFirst branch virtual Network\x1b[0m/g"
az network vnet create --resource-group branch-rg --location eastus --name vnet-br01 --address-prefixes 172.10.0.0/16 --subnet-name Outside --subnet-prefix 172.10.0.0/24  --network-security-group br-01-nsg  --query '{Name:newVNet.name,Resource_Group:newVNet.resourceGroup,Region:newVNet.location,Address_Space:newVNet.addressSpace.addressPrefixes[0] }' -o table
sleep 5
out=$(az network vnet show --name vnet-br01 -g branch-rg --query subnets[0].name)
in=$(az network vnet subnet create --resource-group branch-rg --name Inside --vnet-name vnet-br01 --address-prefix 172.10.1.0/24 --network-security-group br-01-nsg --query name)
vm=$(az network vnet subnet create --resource-group branch-rg --name VM --vnet-name vnet-br01 --address-prefix 172.10.2.0/24 --network-security-group br-01-nsg --query name)
bst=$(az network vnet subnet create --resource-group branch-rg --name AzureBastionSubnet --vnet-name vnet-br01 --address-prefix 172.10.3.0/24  --query name)

printf "\nThe subnets for vnet-br01 will be:\n" | sed -e "s/vnet-br01/ \x1b[33mvnet-br01\x1b[0m/g"
sbnets=($out $in $vm $bst)
for s in "${sbnets[@]}"
do
    sbn=$(echo $s | sed 's/^"\(.*\)"$/\1/')
    addr=$(az network vnet subnet show --name $sbn --vnet-name vnet-br01 --resource-group branch-rg --query addressPrefix)
    printf "\n\x1b[33m${s}\x1b[0m - ${addr}" 
done

printf "\n********Second branch Virtual Network ********\n" | sed -e "s/Second branch Virtual Network/ \x1b[32mSecond branch Virtual Network\x1b[0m/g"
az network vnet create --resource-group branch-rg --location eastus2 --name vnet-br02 --address-prefixes 172.20.0.0/16 --subnet-name Outside --subnet-prefix 172.20.0.0/24 --network-security-group br-02-nsg --query '{Name:newVNet.name,Resource_Group:newVNet.resourceGroup,Region:newVNet.location,Address_Space:newVNet.addressSpace.addressPrefixes[0] }' -o table
sleep 5
out2=$(az network vnet show --name vnet-br01 -g branch-rg --query subnets[0].name)
in2=$(az network vnet subnet create --resource-group branch-rg --name Inside --vnet-name vnet-br02 --address-prefix 172.20.1.0/24 --network-security-group br-02-nsg --query name)
vm2=$(az network vnet subnet create --resource-group branch-rg --name VM --vnet-name vnet-br02 --address-prefix 172.20.2.0/24 --network-security-group br-02-nsg --query name)
bst=$(az network vnet subnet create --resource-group branch-rg --name AzureBastionSubnet --vnet-name vnet-br02 --address-prefix 172.20.3.0/24  --query name)

printf "\nThe subnets for the vnet-br02 will be:\n" | sed -e "s/vnet-br02/ \x1b[33mvnet-br02\x1b[0m/g"
sbnet=($out $in $vm $bst)
for sb in "${sbnet[@]}"
do
    sbnt=$(echo $sb | sed 's/^"\(.*\)"$/\1/')
    addrPr=$(az network vnet subnet show --name $sbnt --vnet-name vnet-br02 --resource-group branch-rg --query addressPrefix)
    printf "\n\x1b[33m${sb}\x1b[0m - ${addrPr}" 
done

echo "\n******** Creating the Routers ********\n\n" | sed -e "s/Creating the Routers/ \x1b[32mCreating the Routers\x1b[0m/g"
az vm image terms accept --urn cisco:cisco-csr-1000v:17_3_3-byol:17.3.320210317 --query '{Publisher:publisher, Product:product}'
az network public-ip create --name br-01-pip --resource-group branch-rg --idle-timeout 30 --allocation-method Static --sku Standard --output none
az network nic create --name br01Out --resource-group branch-rg --vnet-name vnet-br01 --subnet Outside --public-ip-address br-01-pip --private-ip-address 172.10.0.4 --ip-forwarding --output none --out
az network nic create --name br01In --resource-group branch-rg --vnet-name vnet-br01 --subnet Inside --private-ip-address 172.10.1.4 --ip-forwarding --output none
az vm create --resource-group branch-rg --location eastus --name br-01 --size Standard_D2_v2 --nics br01Out br01In --image cisco:cisco-csr-1000v:17_3_3-byol:17.3.320210317 --admin-username aznet --admin-password Networking2022# --output none
sleep 5
pip=$(az network public-ip show --name br-01-pip --resource-group branch-rg --query ipAddress)
br01=$(az vm show --name br-01 --resource-group branch-rg --query name)
printf "\n\x1b[32m${br01}\x1b[0m will have \n\x1b[33m${pip}\x1b[0m as public IP address."

az network public-ip create --name br-02-pip --resource-group branch-rg --location eastus2 --idle-timeout 30 --allocation-method Static --sku Standard --output none
az network nic create --name br02Out --resource-group branch-rg --location eastus2 --vnet-name vnet-br02 --subnet Outside --public-ip-address br-02-pip --private-ip-address 172.20.0.4 --ip-forwarding --output none
az network nic create --name br02In --resource-group branch-rg --location eastus2 --vnet-name vnet-br02 --subnet Inside --private-ip-address 172.20.1.4 --ip-forwarding --output none
az vm create --resource-group branch-rg --location eastus2 --name br-02 --size Standard_D2_v2 --nics br02Out br02In --image cisco:cisco-csr-1000v:17_3_3-byol:17.3.320210317 --admin-username aznet --admin-password Networking2022# --output none
sleep 5
pip2=$(az network public-ip show --name br-02-pip --resource-group branch-rg --query ipAddress)
br02=$(az vm show --name br-02 --resource-group branch-rg --query name)
printf "\n\x1b[32m${br02}\x1b[0m will have \n\x1b[33m${pip2}\x1b[0m as public IP address.\n"

printf "\n******** Creating the Bastion ********\n" | sed -e "s/Creating the Bastion/ \x1b[32mCreating the Bastion\x1b[0m/g"
az network public-ip create --name br01-bastion-pip --resource-group branch-rg --idle-timeout 30 --allocation-method Static --sku Standard --location eastus --output none
az network bastion create --location eastus --name br01-bst --public-ip-address br01-bastion-pip --resource-group branch-rg --vnet-name vnet-br01 --output none

az network public-ip create --name br02-bastion-pip --resource-group branch-rg --idle-timeout 30 --allocation-method Static --sku Standard --location eastus2 --output none
az network bastion create --location eastus2 --name br02-bst --public-ip-address br02-bastion-pip --resource-group branch-rg --vnet-name vnet-br02 --output none

printf "\n\x1b[32mvnet-br01\x1b[0m will have \n\x1b[33m$br01-bastion\x1b[0m as bastion host.\n"
printf "\n\x1b[32mvnet-br02\x1b[0m will have \n\x1b[33m$br02-bst\x1b[0m as bastion host.\n"

printf "\n******** Creating the  VM ********\n" | sed -e "s/Creating the VM/ \x1b[32mCreating the VM\x1b[0m/g"
az network nic create --resource-group branch-rg --name br01-vmnic --location eastus --subnet VM --private-ip-address 172.10.2.100 --vnet-name vnet-br01 --output none
az vm create --name vm-br01 --resource-group branch-rg --location eastus --image Win2012R2Datacenter --nics br01-vmnic --admin-username aznet --admin-password Networking2022# --output

az network nic create --resource-group branch-rg --name br02-vmnic --location eastus2 --subnet VM --private-ip-address 172.20.2.100 --vnet-name vnet-br02 
az vm create --name vm-br02 --resource-group branch-rg --location eastus2 --image Win2012R2Datacenter --nics br02-vmnic --admin-username aznet --admin-password Networking2022# 

printf "The connectivity test will be ran from the VMs below according to their respctive branches:\n"
printf "\nBranch 1: \x1b[32mvm-br01\x1b[0m - \n\x1b[33m172.10.2.100\x1b[0m as bastion host."
printf "\nBranch 1: \x1b[32mvm-br02\x1b[0m - \n\x1b[33m172.20.2.100\x1b[0m as bastion host.\n"

printf  "\n******** Creating the Route tables ********\n" | sed -e "s/Creating the Route tables/ \x1b[32mCreating the Route tables\x1b[0m/g"
az network route-table create --name br01-rt --resource-group branch-rg --location eastus --output none
az network route-table route create --name br02-vnet --resource-group branch-rg --route-table-name br01-rt --address-prefix 172.20.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.10.1.4 --output none
az network route-table route create --name vnet-west --resource-group branch-rg --route-table-name br01-rt --address-prefix 10.100.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.10.1.4 --output none
az network route-table route create --name vnet-east --resource-group branch-rg --route-table-name br01-rt --address-prefix 10.200.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.10.1.4 --output none
az network route-table route create --name vnet-west-01 --resource-group branch-rg --route-table-name br01-rt --address-prefix 10.110.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.10.1.4 --output none
az network route-table route create --name vnet-west-02 --resource-group branch-rg --route-table-name br01-rt --address-prefix 10.120.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.10.1.4 --output none
az network route-table route create --name vnet-east-01 --resource-group branch-rg --route-table-name br01-rt --address-prefix 10.210.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.10.1.4 --output none
az network route-table route create --name vnet-east-02 --resource-group branch-rg --route-table-name br01-rt --address-prefix 10.220.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.10.1.4 --output none
az network vnet subnet update --name VM --vnet-name vnet-br01 --resource-group branch-rg --route-table br01-rt --output none

az network route-table create --name br02-rt --resource-group branch-rg --location eastus2 --output none
az network route-table route create --name br01-vnet --resource-group branch-rg --route-table-name br02-rt --address-prefix 172.10.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.20.1.4 --output none
az network route-table route create --name vnet-west --resource-group branch-rg --route-table-name br02-rt --address-prefix 10.100.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.20.1.4 --output none
az network route-table route create --name vnet-east --resource-group branch-rg --route-table-name br02-rt --address-prefix 10.200.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.20.1.4 --output none
az network route-table route create --name vnet-west-01 --resource-group branch-rg --route-table-name br02-rt --address-prefix 10.110.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.20.1.4 --output none
az network route-table route create --name vnet-west-02 --resource-group branch-rg --route-table-name br02-rt --address-prefix 10.120.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.20.1.4 --output none
az network route-table route create --name vnet-east-01 --resource-group branch-rg --route-table-name br02-rt --address-prefix 10.210.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.20.1.4 --output none
az network route-table route create --name vnet-east-02 --resource-group branch-rg --route-table-name br02-rt --address-prefix 10.220.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 172.20.1.4 --output none
az network vnet subnet update --name VM --vnet-name vnet-br02 --resource-group branch-rg --route-table br02-rt --output none

printf "\nThe routing tables \x1b[32mbr01-rt\x1b[0m and \n\x1b[33mbr02-rt\x1b[0m have been configured for their different branches.\n"

#printf  "******** Gathering the data for the IPSec tunnels ********\n" | sed -e "s/Gathering the data for the IPSec tunnels / \x1b[32mGathering the data for the IPSec tunnels \x1b[0m/g"

#az network vnet-gateway list --resource-group azcloud-rg --query [].[name,bgpSettings.asn,bgpSettings.bgpPeeringAddress] -o table 
