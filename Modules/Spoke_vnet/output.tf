output "spokeName" {
    value = azurerm_virtual_network.spoke.name
    description = "Spoke vnet's name"
}

output "spokeVMName" {
    value = azurerm_linux_virtual_machine.spokevm.name
    description = "Spoke VM.s name"  
}

output "spokeVMIP" {
    value = azurerm_network_interface.vmnic.private_ip_address
    description = "IP of the Spoke VM"
  
}