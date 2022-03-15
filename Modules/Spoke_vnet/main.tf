resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${var.prefix}-02"
  address_space       = [var.spokeAppdressSpace]
  location            = var.location
  resource_group_name = var.group

  tags = var.labtags
}

resource "azurerm_subnet" "vm" {
  name                 = "vm"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.spokeAddressPrefix]
  depends_on = [
    azurerm_virtual_network.spoke
  ]
}

resource "azurerm_network_interface" "vmnic" {
  name                = "${var.prefix}-spoke-vmnic"
  resource_group_name = var.group
  location            = var.location

  ip_configuration {
    name                          = "${var.prefix}-spoke-vm-ipconfig"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Static"
    private_ip_address = "${var.spokePrefix}.10"

  }

  tags = var.labtags
}

resource "azurerm_linux_virtual_machine" "spokevm" {
  name                            = "${var.prefix}-spoke-vm"
  resource_group_name             = var.group
  location                        = var.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.vmnic.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest" 
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb = 100

  }
  tags = var.labtags
}


