 resource "azurerm_network_security_group" "appgw_nsg" {
    name                = "web-${var.prefix}-nsg"
    location            = var.location
    resource_group_name = var.group

    security_rule {
        name                       = "Allow SSH"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
     }

     security_rule {
        name                       = "Allow HTTP"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
     }
    tags = var.labtags
}

resource "azurerm_virtual_network" "app" {
  name                = "vnet-${var.prefix}-01"
  address_space       = [var.appdressSpace]
  location            = var.location
  resource_group_name = var.group

  tags = var.labtags
}

resource "azurerm_subnet" "appgw" {
  name                 = "Apps"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = [var.appAddressPrefix]
  depends_on = [
    azurerm_virtual_network.app
  ]
}

resource "azurerm_subnet" "backend" {
  name                 = "Backend"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = [var.backendAddressPrefix]
  depends_on = [
    azurerm_virtual_network.app
  ]
}

resource "azurerm_application_gateway" "appgw_web" {
  name                = "appgw-${var.prefix}"
  resource_group_name = var.group
  location            = var.location


  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2

  }

  gateway_ip_configuration {
    name      = "appgw-${var.prefix}-ipconf"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "appgw-${var.prefix}-feport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-${var.prefix}-feipconf"
    private_ip_address  = "${var.appPrefix}.10"
    private_ip_address_allocation = "Static"
    subnet_id = azurerm_subnet.appgw.id

  }

  backend_address_pool {
    name = "appgw-${var.prefix}-pool"
  }

  backend_http_settings {
    name                  = "appgw-${var.prefix}-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-traffic"
    frontend_ip_configuration_name = "appgw-${var.prefix}-feipconf"
    frontend_port_name             = "http-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "appgw-${var.prefix}-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-traffic"
    backend_address_pool_name  = "appgw-${var.prefix}-pool"
    backend_http_settings_name = "appgw-${var.prefix}-settings"
  }
  tags = var.labtags
}

resource "azurerm_network_interface" "appvmnic" {
  count                = 2
  name                = "${var.prefix}-app0${count.index + 1}-vmnic"
  resource_group_name = var.group
  location            = var.location

  ip_configuration {
    name                          = "${var.prefix}-app0${count.index + 1}-ipconfig"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Static"
    private_ip_address = "${var.appPrefix}.10${count.index + 1}"

  }
  tags = var.labtags
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appgwnic-assoc" {
  count = 2
  network_interface_id    = azurerm_network_interface.appvmnic[count.index].id
  ip_configuration_name   = "appvmni0${count.index+1}-ipconfig"
  backend_address_pool_id = azurerm_application_gateway.appgw_web.backend_address_pool[0].id
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.appgw_nsg.id
}

data "template_file" "web_server" {
    template = file ("../scripts/webserver.sh")  
}

resource "azurerm_linux_virtual_machine" "web" {
  count                            = 2
  name                            =  "${var.prefix}-web0${count.index + 1}"
  resource_group_name             = var.group
  location                        = var.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [element(azurerm_network_interface.appvmnic.*.id, count.index + 1)]
  computer_name = azurerm_linux_virtual_machine.web.name
  custom_data = base64encode(data.template_file.web_server.rendered)

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