data "azurerm_virtual_network" "vnet_01" {
    name = var.vnet01
    resource_group_name = var.group
}

data "azurerm_virtual_network" "vnet_02" {
    name = var.vnet02
    resource_group_name = var.group
  
}

resource "azurerm_virtual_network_peering" "peer12" {
    name = "${data.azurerm_virtual_network.vnet_01.name}-to-${data.azurerm_virtual_network.vnet_02.name}"
    resource_group_name = data.azurerm_virtual_network.vnet_01.resource_group_name
    virtual_network_name = data.azurerm_virtual_network.vnet_01.name
    remote_virtual_network_id = data.azurerm_virtual_network.vnet_02.id
    allow_forwarded_traffic = true
    allow_gateway_transit = false 
    allow_virtual_network_access = true 
    use_remote_gateways = false  
}

resource "azurerm_virtual_network_peering" "peer21" {
    name = "${data.azurerm_virtual_network.vnet_02.name}-to-${data.azurerm_virtual_network.vnet_01.name}"
    resource_group_name = data.azurerm_virtual_network.vnet_02.resource_group_name
    virtual_network_name = data.azurerm_virtual_network.vnet_02.name
    remote_virtual_network_id = data.azurerm_virtual_network.vnet_01.id
    allow_forwarded_traffic = true
    allow_gateway_transit = false 
    allow_virtual_network_access = true 
    use_remote_gateways = false
}