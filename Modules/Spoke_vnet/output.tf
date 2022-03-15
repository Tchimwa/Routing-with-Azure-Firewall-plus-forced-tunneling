output "spokeName" {
    value = azurerm_virtual_network.spoke.resource_group_name
    description = "Spoke vnet's name"
}

output "spokeVMName" {
    value = azurerm_linux_virtual_machine.spokevm.vm
    description = "Spoke VM.s name"  
}

output "spokeVMIP" {
    value = azurerm_network_interface.vmnic.private_ip_address
    description = "IP of the Spoke VM"
  
}