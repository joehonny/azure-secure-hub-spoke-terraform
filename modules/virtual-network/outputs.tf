output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of stable subnet keys to subnet resource IDs."
  value = {
    for subnet_key, subnet in azurerm_subnet.this :
    subnet_key => subnet.id
  }
}
