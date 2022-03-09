#!/bin/bash

#Creating a resource Group for the On-premises for the Cisco CSR router

az group create --name branch-rg --location eastus

#Creating the On-premises VNET to host the router

az network nsg create --name csr-nsg --resource-group branch-rg --location eastus 
az network nsg rule create --name Allow-NSG --nsg-name csr-nsg --resource-group branch-rg --access Allow --description "Allowing SSH to the VM" --priority 110 --protocol TCP --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22

az network vnet create --resource-group branch-rg --location eastus --name On-premises --address-prefixes 192.168.0.0/16 --subnet-name Outside --subnet-prefix 192.168.0.0/24
az network vnet subnet create --resource-group branch-rg --name Inside --vnet-name On-premises --address-prefix 192.168.1.0/24 --network-security-group csr-nsg
az network vnet subnet create --resource-group branch-rg --name VM --vnet-name On-premises --address-prefix 192.168.2.0/24 --network-security-group csr-nsg
az network vnet subnet create --resource-group branch-rg --name AzureBastionSubnet --vnet-name On-premises --address-prefix 192.168.3.0/24
