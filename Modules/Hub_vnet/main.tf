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
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hubbstAddressPrefix]
}

resource "azurerm_subnet" "fw" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hubfwAddressPrefix]
}

resource "azurerm_subnet" "fw-mgmt" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hubfwmgmtAddressPrefix]
}

resource "azurerm_subnet" "apps" {
  name                 = "Apps-${var.prefix}"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hubappsAddressPrefix]
}

resource "azurerm_subnet" "servers" {
  name                 = "Servers-${var.prefix}"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hubsrvAddressPrefix]
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
    name                 = "bst${var.prefix}-ipcfg"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bst-pip.id
  }
  tags       = merge({ "Resource Name" = "bst-${var.prefix}" }, var.labtags)
  
}

resource "azurerm_network_interface" "hubapps-nic" {
  name                = "${var.prefix}apps-nic"
  resource_group_name = var.group
  location            = var.location

  ip_configuration {
    name                          = "${var.prefix}apps-ipcfg"
    subnet_id                     = azurerm_subnet.apps.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.hubappsPrefix}.100"
  }
 
  tags = merge({ "Resource Name" = "${var.prefix}apps-nic" }, var.labtags)
}

resource "azurerm_network_interface" "hubsrv-nic" {
  name                = "${var.prefix}srv-nic"
  resource_group_name = var.group
  location            = var.location

  ip_configuration {
    name                          = "${var.prefix}srv-ipcfg"
    subnet_id                     = azurerm_subnet.servers.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.hubsrvPrefix}.100"
  }

  tags = merge({ "Resource Name" = "${var.prefix}srv-nic" }, var.labtags)
}

resource "azurerm_windows_virtual_machine" "apps-vm" {
  name                = "${var.prefix}-apps"
  resource_group_name = var.group
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [azurerm_network_interface.hubapps-nic.id]

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
  tags = merge({ "Resource Name" = "${var.prefix}apps-vm" }, var.labtags)
}

resource "azurerm_windows_virtual_machine" "srv-vm" {
  name                = "${var.prefix}-srv"
  resource_group_name = var.group
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [azurerm_network_interface.hubsrv-nic.id]


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
  tags = merge({ "Resource Name" = "${var.prefix}srv-vm" }, var.labtags)
}

