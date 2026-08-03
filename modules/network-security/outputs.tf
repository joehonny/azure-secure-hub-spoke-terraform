output "network_security_group_ids" {
  description = "Map of stable subnet keys to network security group resource IDs."
  value = {
    for subnet_key, network_security_group in azurerm_network_security_group.this :
    subnet_key => network_security_group.id
  }
}

output "subnet_associations" {
  description = "Map of stable subnet keys to network security group association details."
  value = {
    for subnet_key, association in azurerm_subnet_network_security_group_association.this :
    subnet_key => {
      id                        = association.id
      subnet_id                 = association.subnet_id
      network_security_group_id = association.network_security_group_id
    }
  }
}
