data "azurerm_subnet" "vpngw-sbnt" {
    name = "GatewaySubnet"
    virtual_network_name = "vnet-${var.prefix}"
    resource_group_name = var.group
  
}

resource "azurerm_public_ip" "vpngw-pip" {
  name                = "vpngw-${var.prefix}-pip"
  location            = var.location
  resource_group_name = var.group
  allocation_method   = "Dynamic"
  tags                = merge({ "Resource Name:" = "vpn-gw-${var.prefix}" }, var.labtags)
}

resource "azurerm_virtual_network_gateway" "vpngw" {
  name                = "vpn-gw-${var.prefix}"
  location            = var.location
  resource_group_name = var.group

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw1"
  bgp_settings {
    asn = var.bgpasn
  }
  ip_configuration {
    name                          = "gw${var.prefix}-ipcfg"
    public_ip_address_id          = azurerm_public_ip.vpngw-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.vpngw-sbnt.id
  }
  tags = merge({ "Resource Name" = "vpn-gw-${var.prefix}" }, var.labtags)
}