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

module "Hub_east" {
  source               = "./Modules/Hub_vnet"
  group                = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  prefix               = var.Prefix[1]
  hubAddressSpace = var.HubAddressSpace[1]
  hubgwAddressPrefix = var.HubgwAddressPrefix[1]
  hubbstAddressPrefix = var.HubbstAddressPrefix[1]
  hubfwAddressPrefix = var.HubfwAddressPrefix[1]
  hubfwmgmtAddressPrefix = var.HubfwmgmtAddressPrefix[1]
  hubappsAddressPrefix = var.HubappsAddressPrefix[1]
  hubsrvAddressPrefix = var.HubsrvAddressPrefix[1]
    hubappsPrefix = var.HubappsPrefix[1]
  hubsrvPrefix  = var.HubsrvPrefix[1]
  bgpasn = var.BgpAsn[1]
  username             = var.Username
  password             = var.Password
  labtags              = azurerm_resource_group.main.tags  
}

module "Hub_west" {
  source               = "./Modules/Hub_vnet"
  group                = azurerm_resource_group.main.name
  location             = var.Peered_loc
  prefix               = var.Prefix[0]
  hubAddressSpace = var.HubAddressSpace[0]
  hubgwAddressPrefix = var.HubgwAddressPrefix[0]
  hubbstAddressPrefix = var.HubbstAddressPrefix[0]
  hubfwAddressPrefix = var.HubfwAddressPrefix[0]
  hubfwmgmtAddressPrefix = var.HubfwmgmtAddressPrefix[0]
  hubappsAddressPrefix = var.HubappsAddressPrefix[0]
  hubsrvAddressPrefix = var.HubsrvAddressPrefix[0]
    hubappsPrefix = var.HubappsPrefix[0]
  hubsrvPrefix  = var.HubsrvPrefix[0]
  bgpasn = var.BgpAsn[0]
  username             = var.Username
  password             = var.Password
  labtags              = azurerm_resource_group.main.tags  
}


module "Appgw_east" {
  source               = "./Modules/Appgw_vnet"
  group                = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  prefix               = var.Prefix[1]
  appAddressPrefix     = var.AppAddressPrefix[1]
  backendAddressPrefix = var.BackendAddressPrefix[1]
  appAddressSpace      = var.AppAddressSpace[1]
  appPrefix            = var.SpokePrefix[1]
  username             = var.Username
  password             = var.Password
  labtags              = azurerm_resource_group.main.tags
}

module "Appgw_west" {
  source               = "./Modules/Appgw_vnet"
  group                = azurerm_resource_group.main.name
  location             = var.Peered_loc
  prefix               = var.Prefix[0]
  appAddressPrefix     = var.AppAddressPrefix[0]
  backendAddressPrefix = var.BackendAddressPrefix[0]
  appAddressSpace      = var.AppAddressSpace[0]
  appPrefix            = var.SpokePrefix[0]
  username             = var.Username
  password             = var.Password
  labtags              = azurerm_resource_group.main.tags
}

module "spoke_east" {
  source             = "./Modules/Spoke_vnet"
  group              = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  prefix             = var.Prefix[1]
  spokeAddressPrefix = var.SpokeAddressPrefix[1]
  spokeAddressSpace  = var.SpokeAddressSpace[1]
  spokePrefix        = var.SpokePrefix[1]
  username           = var.Username
  password           = var.Password
  labtags            = azurerm_resource_group.main.tags
}

module "spoke_west" {
  source             = "./Modules/Spoke_vnet"
  group              = azurerm_resource_group.main.name
  location           = var.Peered_loc
  prefix             = var.Prefix[0]
  spokeAddressPrefix = var.SpokeAddressPrefix[0]
  spokeAddressSpace  = var.SpokeAddressSpace[0]
  spokePrefix        = var.SpokePrefix[0]
  username           = var.Username
  password           = var.Password
  labtags            = azurerm_resource_group.main.tags
}