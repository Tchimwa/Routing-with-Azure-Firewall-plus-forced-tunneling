output "appgw_name" {
  value       = azurerm_application_gateway.appgw_web.name
  description = "AppGW's name"
}

output "appgw-ipaddress" {
  value       = azurerm_application_gateway.appgw_web.frontend_ip_configuration[1].private_ip_address
  description = "Frontend Private IP Address"
}

output "app_vnet" {
  value = azurerm_virtual_network.app.name
  description = "Appgw Spoke VNET name"
}


