resource "azurerm_virtual_network_peering" "local_to_remote" {
  name                      = "${var.local_vnet_name}-to-${var.remote_vnet_name}"
  resource_group_name       = var.local_resource_group_name
  virtual_network_name      = var.local_vnet_name
  remote_virtual_network_id = var.remote_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "remote_to_local" {
  name                      = "${var.remote_vnet_name}-to-${var.local_vnet_name}"
  resource_group_name       = var.remote_resource_group_name
  virtual_network_name      = var.remote_vnet_name
  remote_virtual_network_id = var.local_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
