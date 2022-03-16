terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.Subscription_id
  client_id       = var.Client_id
  client_secret   = var.Client_secret
  tenant_id       = var.Tenant_id

}

resource "azurerm_resource_group" "main" {
  name     = "azcloud-rg"
  location = "eastus"
  tags = {
    Deployment_type = "Terraform"
    Project         = "LABTIME"
    Environment     = "Azure"
  }
}

module "spoke_east" {
  source             = "./Modules/Spoke_vnet"
  group              = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  prefix             = var.Prefix[1]
  spokeAddressPrefix = var.SpokeAddressPrefix[1]
  spokeAppdressSpace = var.SpokeAppdressSpace[1]
  spokePrefix        = var.SpokePrefix[1]
  username           = "aznet"
  password           = "Networking2022#"
  labtags            = azurerm_resource_group.main.tags
}

module "spoke_west" {
  source             = "./Modules/Spoke_vnet"
  group              = azurerm_resource_group.main.name
  location           = "westus"
  prefix             = var.Prefix[0]
  spokeAddressPrefix = var.SpokeAddressPrefix[0]
  spokeAppdressSpace = var.SpokeAppdressSpace[0]
  spokePrefix        = var.SpokePrefix[0]
  username           = "aznet"
  password           = "Networking2022#"
  labtags            = azurerm_resource_group.main.tags
}