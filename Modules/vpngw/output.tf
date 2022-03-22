output "vpn-gw-name" {
  value       = azurerm_virtual_network_gateway.vpngw.name
  description = "VPN GW's name"
}

output "vpn-gw-pip" {
  value       = azurerm_public_ip.vpngw-pip.ip_address
  description = "VPN GW's public IP"
}

output "bgp-asn" {
  value       = azurerm_virtual_network_gateway.vpngw.bgp_settings[0].asn
  description = "BGP ASN"

}

output "bgp-peer-ipaddress" {
  value       = azurerm_virtual_network_gateway.vpngw.bgp_settings[0].peering_address
  description = "BGP Peer IP address"
}