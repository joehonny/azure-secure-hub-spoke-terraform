resource "azurerm_route_table" "this" {
  for_each = var.subnet_ids

  name                = "${var.name_prefix}-${each.key}-rt"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = var.subnet_ids

  subnet_id      = each.value
  route_table_id = azurerm_route_table.this[each.key].id
}
