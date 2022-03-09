#!/bin/bash

#Creating a resource Group for the On-premises for the Cisco CSR router

az group create --name branch-rg --location eastus

#Creating the On-premises VNET to host the router

az network nsg create --name csr01-nsg --resource-group branch-rg --location eastus 
az network nsg rule create --name Allow-NSG --nsg-name csr-nsg --resource-group branch-rg --access Allow --description "Allowing SSH to the VM" --priority 110 --protocol TCP --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22

az network vnet create --resource-group branch-rg --location eastus --name On-premises --address-prefixes 192.168.0.0/16 --subnet-name Outside --subnet-prefix 192.168.0.0/24
az network vnet subnet create --resource-group branch-rg --name Inside --vnet-name On-premises --address-prefix 192.168.1.0/24 --network-security-group csr-nsg
az network vnet subnet create --resource-group branch-rg --name VM --vnet-name On-premises --address-prefix 192.168.2.0/24 --network-security-group csr-nsg
az network vnet subnet create --resource-group branch-rg --name AzureBastionSubnet --vnet-name On-premises --address-prefix 192.168.3.0/24

#Creating the Router

az network public-ip create --name csr-pip --resource-group branch-rg --idle-timeout 30 --allocation-method Static --sku Standard
az network nic create --name csrnicOut01 --resource-group branch-rg --vnet On-premises --subnet Outside --public-ip-address csr-pip --private-ip-address 192.168.0.4 --ip-forwarding
az network nic create --name csrnicIn01 --resource-group branch-rg --vnet On-premises --subnet Inside --private-ip-address 192.168.1.4 --ip-forwarding
az vm create --resource-group branch-rg --location eastus --name csr01v --size Standard_D2_v2 --nics csrnicOut01 csrnicIn01 --image cisco:cisco-csr-1000v:17_3_3-byol:17.3.320210317 --admin-username azure --admin-password Networking2021#

#Creating the VM on the On-premises VNET for testing

az network public-ip create --name csrbastion-pip --resource-group branch-rg --idle-timeout 30 --allocation-method Static --sku Standard --location eastus
az network bastion create --location eastus --name csr-bastion --public-ip-address csrbastion-pip --resource-group branch-rg --vnet-name On-premises

az network nic create --name vmnic01 --resource-group branch-rg --vnet On-premises --subnet VM --private-ip-address 192.168.2.100 --ip-forwarding
az vm create --name VM --resource-group branch-rg --location eastus --image  UbuntuLTS --nics vmnic01 --admin-username azure --admin-password Networking2021# 

az network nic create --name vminnic01 --resource-group branch-rg --vnet On-premises --subnet Inside --private-ip-address 192.168.1.100 --ip-forwarding
az vm create --name VM-Inside --resource-group branch-rg --location eastus --image  UbuntuLTS --nics vminnic01 --admin-username azure --admin-password Networking2021# 

#Creation of the route table

az network route-table create --name OnPrem-RT --resource-group branch-rg --location eastus
az network route-table route create --name Hub-rte --resource-group branch-rg --route-table-name OnPrem-RT --address-prefix 192.168.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 192.168.1.4
az network route-table route create --name Spoke-rte --resource-group branch-rg --route-table-name OnPrem-RT --address-prefix 100.0.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 192.168.1.4
az network route-table route create --name Branch-rte --resource-group branch-rg --route-table-name OnPrem-RT --address-prefix 10.10.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 192.168.1.4
az network vnet subnet update --name VM --vnet-name On-premises --resource-group branch-rg --route-table OnPrem-RT
az network vnet subnet update --name Inside --vnet-name On-premises --resource-group branch-rg --route-table OnPrem-RT