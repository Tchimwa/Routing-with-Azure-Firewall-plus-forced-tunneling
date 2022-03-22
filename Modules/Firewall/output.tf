output "fw-name" {
  value       = azurerm_firewall.fw.name
  description = "FW name"
}

output "fw-ipaddress" {
  value       = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  description = "FW private IP address"
}