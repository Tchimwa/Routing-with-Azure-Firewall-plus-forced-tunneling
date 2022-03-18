resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.prefix}"
  address_space       = [var.hubAddressSpace]
  location            = var.location
  resource_group_name = var.group

  tags = merge({ "Resource Name:" = "vnet-${var.prefix}" }, var.labtags)
}

resource "azurerm_subnet" "gw" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hubgwAddressPrefix]
  depends_on           = [azurerm_virtual_network.hub]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hubbstAddressPrefix]
  depends_on           = [azurerm_virtual_network.hub]
}

resource "azurerm_subnet" "fw" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hubfwAddressPrefix]
  depends_on           = [azurerm_virtual_network.hub]
}

resource "azurerm_subnet" "fw-mgmt" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hubfwmgmtAddressPrefix]
  depends_on           = [azurerm_virtual_network.hub]
}

resource "azurerm_subnet" "apps" {
  name                 = "Apps-${var.prefix}"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hubappsAddressPrefix]
  depends_on           = [azurerm_virtual_network.hub]
}

resource "azurerm_subnet" "servers" {
  name                 = "Servers-${var.prefix}"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hubsrvAddressPrefix]
  depends_on           = [azurerm_virtual_network.hub]
}

resource "azurerm_public_ip" "vpngw-pip" {
  name                = "vpn-gw-${var.prefix}"
  location            = var.location
  resource_group_name = var.group
  allocation_method   = "Dynamic"
  tags                = merge({ "Resource Name:" = "vpn-gw-${var.prefix}" }, var.labtags)
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

resource "azurerm_public_ip" "bst-pip" {
  name                = "bst-${var.prefix}-pip"
  location            = var.location
  resource_group_name = var.group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge({ "Resource Name" = "bst-${var.prefix}-pip" }, var.labtags)
}

resource "azurerm_bastion_host" "bst-host" {
  name                = "bst-${var.prefix}"
  location            = var.location
  resource_group_name = var.group

  ip_configuration {
    name                 = "bst-${var.prefix}-ipconfig"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bst-pip.id
  }
  tags       = merge({ "Resource Name" = "bst-${var.prefix}" }, var.labtags)
  depends_on = [azurerm_virtual_network.hub]
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
    name                          = "vpngw-${var.prefix}-ipconfig"
    public_ip_address_id          = azurerm_public_ip.vpngw-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw.id
  }
  tags       = merge({ "Resource Name" = "vpn-gw-${var.prefix}" }, var.labtags)
  depends_on = [azurerm_virtual_network.hub]
}

resource "azurerm_firewall" "fw" {
  name                = "fw-${var.prefix}"
  location            = var.location
  resource_group_name = var.group 

  ip_configuration {
    name                 = "fw-${var.prefix}-ipconfig"
    subnet_id            = azurerm_subnet.fw.id
    public_ip_address_id = azurerm_public_ip.fw-pip.id
  }
  management_ip_configuration {
    name                 = "fwmgmt-${var.prefix}-ipconfig"
    public_ip_address_id = azurerm_public_ip.fw-mgmt-pip.id
    subnet_id            = azurerm_subnet.fw-mgmt.id
  }
  tags       = merge({ "Resource Name" = "fw-${var.prefix}" }, var.labtags)
  depends_on = [azurerm_virtual_network.hub]
}

resource "azurerm_firewall_network_rule_collection" "fw-rule" {
  name                = "fw-${var.prefix}-netrule-col"
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

  depends_on = [azurerm_firewall.fw]
}

resource "azurerm_network_interface" "hubapps-nic" {
  name                = "${var.prefix}-hubapps-vmnic"
  resource_group_name = var.group
  location            = var.location

  ip_configuration {
    name                          = "${var.prefix}-hubappsvm-ipconfig"
    subnet_id                     = azurerm_subnet.apps.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.hubappsPrefix}.10"
  }
  tags = merge({ "Resource Name" = "${var.prefix}-hubapps-vmnic" }, var.labtags)
}

resource "azurerm_network_interface" "hubsrv-nic" {
  name                = "${var.prefix}-hubsrv-vmnic"
  resource_group_name = var.group
  location            = var.location

  ip_configuration {
    name                          = "${var.prefix}-hubsrvvm-ipconfig"
    subnet_id                     = azurerm_subnet.servers.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.hubsrvPrefix}.10"
  }
  tags = merge({ "Resource Name" = "${var.prefix}-hubsrv-vmnic" }, var.labtags)
}

resource "azurerm_windows_virtual_machine" "apps-vm" {
  name                = "${var.prefix}-hubapps-vm"
  resource_group_name = var.group
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.hubapps-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = merge({ "Resource Name" = "${var.prefix}-hubapps-vm" }, var.labtags)
}

resource "azurerm_windows_virtual_machine" "srv-vm" {
  name                = "${var.prefix}-hubsrv-vm"
  resource_group_name = var.group
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.hubsrv-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = merge({ "Resource Name" = "${var.prefix}-hubsrv-vm" }, var.labtags)
}

