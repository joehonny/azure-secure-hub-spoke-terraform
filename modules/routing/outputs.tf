output "route_table_ids" {
  description = "Map of stable subnet keys to route table resource IDs."
  value = {
    for subnet_key, route_table in azurerm_route_table.this :
    subnet_key => route_table.id
  }
}

output "subnet_associations" {
  description = "Map of stable subnet keys to route table association details."
  value = {
    for subnet_key, association in azurerm_subnet_route_table_association.this :
    subnet_key => {
      id             = association.id
      subnet_id      = association.subnet_id
      route_table_id = association.route_table_id
    }
  }
}
