terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0"
    }
  }
}

provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "main" {
  name     = "${var.alias}-azcloud-rg"
  location = "eastus"
  tags = {
    Deployment_type = "Terraform"
    Project         = "LABTIME"
    Environment     = "Azure"
    ResourceGroup   = "${var.alias}-azcloud-rg"
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
  username             = var.Username
  password             = var.Password
  labtags              = azurerm_resource_group.main.tags  
}

module "Hub_centralus" {
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
  username             = var.Username
  password             = var.Password
  labtags              = azurerm_resource_group.main.tags  
}

module "fw-east" {
  source               = "./Modules/Firewall"
  group                = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  prefix               = var.Prefix[1]
  labtags              = azurerm_resource_group.main.tags   

  depends_on = [module.Hub_east]
}

module "fw-centralus" {
  source               = "./Modules/Firewall"
  group                = azurerm_resource_group.main.name
  location             = var.Peered_loc
  prefix               = var.Prefix[0]
  labtags              = azurerm_resource_group.main.tags  
  
  depends_on = [module.Hub_centralus]

}

module "vpngw-eastus" {
  source               = "./Modules/vpngw"
  group                = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  prefix               = var.Prefix[1]
  bgpasn               = var.BgpAsn[1]
  labtags              = azurerm_resource_group.main.tags  
  
  depends_on = [module.Hub_east]
}
module "vpngw-centralus" {
  source               = "./Modules/vpngw"
  group                = azurerm_resource_group.main.name
  location             = var.Peered_loc
  prefix               = var.Prefix[0]
  bgpasn               = var.BgpAsn[0]
  labtags              = azurerm_resource_group.main.tags  
  
  depends_on = [module.Hub_centralus]
}




module "Appgw_central" {
  source               = "./Modules/Appgw_vnet"
  group                = azurerm_resource_group.main.name
  location             = var.Peered_loc
  prefix               = var.Prefix[0]
  appAddressPrefix     = var.AppAddressPrefix[0]
  backendAddressPrefix = var.BackendAddressPrefix[0]
  appAddressSpace      = var.AppAddressSpace[0]
  appPrefix            = var.AppPrefix[0]
  backendPrefix        = var.BackendPrefix[0]
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
  appPrefix            = var.AppPrefix[1]
  backendPrefix        = var.BackendPrefix[1]
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

module "spoke_central" {
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

module "hub_peering" {
  source = "./Modules/peering"
  group = azurerm_resource_group.main.name
  vnet01 = module.Hub_centralus.hubvnet_name
  vnet02 = module.Hub_east.hubvnet_name
}

module "eastappgw_peering" {
  source = "./Modules/peering"
  group = azurerm_resource_group.main.name
  vnet01 = module.Hub_east.hubvnet_name
  vnet02 = module.Appgw_east.app_vnet
}

module "eastspoke_peering" {
  source = "./Modules/peering"
  group = azurerm_resource_group.main.name
  vnet01 = module.Hub_centralus.hubvnet_name
  vnet02 = module.spoke_east.spokeName
}

module "centralappgw_peering" {
  source = "./Modules/peering"
  group = azurerm_resource_group.main.name
  vnet01 = module.Hub_centralus.hubvnet_name
  vnet02 = module.Appgw_central.app_vnet
}

module "centralspoke_peering" {
  source = "./Modules/peering"
  group = azurerm_resource_group.main.name
  vnet01 = module.Hub_centralus.hubvnet_name
  vnet02 = module.spoke_central.spokeName
}