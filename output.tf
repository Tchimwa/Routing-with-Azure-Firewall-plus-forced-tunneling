output "vpngw-eastus-name" {
  value       = module.vpngw-eastus.vpn-gw-name
  description = "East VpnGW name"

}

output "vpngw-eastus-pip" {
  value       = module.vpngw-eastus.vpn-gw-pip
  description = "East VpnGW Ip address"

}

output "vpngw-east-peerip" {
  value       = module.vpngw-eastus.bgp-peer-ipaddress
  description = "East BGP peer-Ip-address"

}

output "east-bgp-asn" {
  value       = module.vpngw-eastus.bgp-asn
  description = "East BGP ASN"

}

output "vpngw-centralus-name" {
  value       = module.vpngw-centralus.vpn-gw-name
  description = "Central-US VpnGW name"

}

output "vpngw-centralus-pip" {
  value       = module.vpngw-centralus.vpn-gw-pip
  description = "Central-US VpnGW Ip address"

}

output "vpngw-centralus-peerip" {
  value       = module.vpngw-centralus.bgp-peer-ipaddress
  description = "Central-US BGP peer-Ip-address"

}

output "central-bgp-asn" {
  value       = module.vpngw-centralus.bgp-asn
  description = "Central BGP ASN"

}

output "fw-east-name" {
  value       = module.fw-east.fw-name
  description = "East FW name"

}

output "fw-east-ip" {
  value       = module.fw-east.fw-ipaddress
  description = "East FW Private IP"

}

output "fw-centralus-name" {
  value       = module.fw-centralus.fw-name
  description = "Central-US FW name"

}

output "fw-centralus-ip" {
  value       = module.fw-centralus.fw-ipaddress
  description = "Central-US FW Private IP"

}

output "appgw-eastus-name" {
  value       = module.Appgw_east.appgw_name
  description = "East AppGW name"

}

output "appgw-eastus-feip" {
  value       = module.Appgw_east.appgw-ipaddress
  description = "East AppGW Frontend Private IP"

}

output "appgw-centralus-name" {
  value       = module.Appgw_central.appgw_name
  description = "Central-US AppGW name"

}

output "appgw-centralus-feip" {
  value       = module.Appgw_central.appgw-ipaddress
  description = "Central-US AppGW Frontend Private IP"

}