output "AppGW_Name" {
  value       = azurerm_application_gateway.appgw_web.name
  description = "AppGW's name"
}

output "AppGW_IPAddress" {
  value       = azurerm_application_gateway.appgw_web.frontend_ip_configuration[0].private_ip_address
  description = "Frontend Private IP Address"
}



