#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'

echo -e "=========== ${RED}Implementation of the On-premises environment{NC} =========="
echo -e "********Resource Group for the On-premises environment********"
sleep 5

az group create --name branch-rg --location eastus --query '{Name:name,Location:location}' -o table
sleep 5

echo -e "********Network Security Group for the routers ********"
sleep 5

nsg01_name=$(az network nsg create --name br-01-nsg --resource-group branch-rg --location eastus --query newNSG.name)
nsg02_name=$(az network nsg create --name br-02-nsg --resource-group branch-rg --location eastus2 --query newNSG.name)

echo -e "BR-01 router's network security group is ${GREEN}$nsg01_name."
echo -e "BR-02 router's network security group is ${GREEN}$nsg02_name."

az network nsg rule create --name Allow-SSH --nsg-name br-01-nsg --resource-group branch-rg --access Allow --description "SSH Ingress Traffic Allowed" --priority 110 --protocol TCP --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22 --query '{Name:name,Source:sourceAddressPrefix,PORT:destinationPortRange,Type:direction,Priority:priority}' --output table
ssh_rule=$(az network nsg rule create --name Allow-SSH --nsg-name br-02-nsg --resource-group branch-rg --access Allow --description "SSH Ingress Traffic Allowed" --priority 110 --protocol TCP --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22 --query Port)

echo -e "********First branch virtual Network ********"
az network vnet create --resource-group branch-rg --location eastus --name vnet-br01 --address-prefixes 172.10.0.0/16 --subnet-name Outside --subnet-prefix 172.10.0.0/24 --query '{Name:newVNet.name,Resource_Group:newVNet.resourceGroup,Region:newVNet.location,Address_Space:newVNet.addressSpace.addressPrefixes[0] }' -o table
sleep 5

echo -e "The subnets for the ${GREEN}vnet-br01${NC} will be:"
az network vnet subnet create --resource-group branch-rg --name Inside --vnet-name vnet-br01 --address-prefix 172.10.1.0/24 --network-security-group br-01-nsg --query '{Subnet:name,Address_Prefix:addressPrefix}' -o table
az network vnet subnet create --resource-group branch-rg --name VM --vnet-name vnet-br01 --address-prefix 172.10.2.0/24 --network-security-group br-01-nsg --query '{Subnet:name,Address_Prefix:addressPrefix}' -o table
az network vnet subnet create --resource-group branch-rg --name AzureBastionSubnet --vnet-name vnet-br01 --address-prefix 172.10.3.0/24  --query '{Subnet:name,Address_Prefix:addressPrefix}' -o table

echo -e "********Second branch Virtual Network ********"
az network vnet create --resource-group branch-rg --location eastus2 --name vnet-br02 --address-prefixes 172.20.0.0/16 --subnet-name Outside --subnet-prefix 172.20.0.0/24 --query '{Name:newVNet.name,Resource_Group:newVNet.resourceGroup,Region:newVNet.location,Address_Space:newVNet.addressSpace.addressPrefixes[0] }' -o table
sleep 5

echo -e "The subnets for the ${GREEN}vnet-br02${NC} will be:"
az network vnet subnet create --resource-group branch-rg --name Inside --vnet-name vnet-br02 --address-prefix 172.20.1.0/24 --network-security-group br-02-nsg --query '{Subnet:name,Address_Prefix:addressPrefix}' -o table
az network vnet subnet create --resource-group branch-rg --name VM --vnet-name vnet-br02 --address-prefix 172.20.2.0/24 --network-security-group br-02-nsg --query '{Subnet:name,Address_Prefix:addressPrefix}' -o table
az network vnet subnet create --resource-group branch-rg --name AzureBastionSubnet --vnet-name vnet-br02 --address-prefix 172.20.3.0/24  --query '{Subnet:name,Address_Prefix:addressPrefix}' -o table


