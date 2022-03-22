data "azurerm_subnet" "fw-sbnt" {
    name = "AzureFirewallSubnet"
    virtual_network_name = "vnet-${var.prefix}"
    resource_group_name = var.group
}

data "azurerm_subnet" "fwmgmt-sbnt" {
    name = "AzureFirewallManagementSubnet"
    virtual_network_name = "vnet-${var.prefix}"
    resource_group_name = var.group
}

resource "azurerm_public_ip" "fw-pip" {
  name                = "fw-${var.prefix}-pip"
  location            = var.location
  resource_group_name = var.group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge({ "Resource Name" = "fw-${var.prefix}-pip" }, var.labtags)
}

resource "azurerm_public_ip" "fw-mgmt-pip" {
  name                = "fwmgmt-${var.prefix}-pip"
  location            = var.location
  resource_group_name = var.group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge({ "Resource Name" = "fwmgmt-${var.prefix}-pip" }, var.labtags)
}

resource "azurerm_firewall" "fw" {
  name                = "fw-${var.prefix}"
  location            = var.location
  resource_group_name = var.group

  ip_configuration {

    name                 = "fw${var.prefix}-ipcfg"
    subnet_id            = data.azurerm_subnet.fw-sbnt.id
    public_ip_address_id = azurerm_public_ip.fw-pip.id
    

  }
  management_ip_configuration {
    name                 = "fwmgmt${var.prefix}-ipcfg"
    public_ip_address_id = azurerm_public_ip.fw-mgmt-pip.id
    subnet_id            = data.azurerm_subnet.fwmgmt-sbnt.id
  }
  tags = merge({ "Resource Name" = "fw-${var.prefix}" }, var.labtags)
}

resource "azurerm_firewall_network_rule_collection" "fw-rule" {
  name                = "${var.prefix}-netrulecol"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_firewall.fw.resource_group_name
  priority            = 110
  action              = "Allow"

  rule {
    name                  = "Allow-All"
    source_addresses      = ["*"]
    destination_ports     = ["*"]
    destination_addresses = ["*"]
    protocols = [
      "TCP",
      "UDP",
    ]
  }
}

