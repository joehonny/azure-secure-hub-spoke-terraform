resource "azurerm_network_security_group" "this" {
  for_each = var.subnet_ids

  name                = "${var.name_prefix}-${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnet_ids

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
