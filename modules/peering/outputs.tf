output "peering_ids" {
  description = "Resource IDs of both directions of the virtual network peering."
  value = {
    local_to_remote = azurerm_virtual_network_peering.local_to_remote.id
    remote_to_local = azurerm_virtual_network_peering.remote_to_local.id
  }
}

output "peering_settings" {
  description = "Security-relevant settings for both directions of the virtual network peering."
  value = {
    local_to_remote = {
      allow_virtual_network_access = azurerm_virtual_network_peering.local_to_remote.allow_virtual_network_access
      allow_forwarded_traffic      = azurerm_virtual_network_peering.local_to_remote.allow_forwarded_traffic
      allow_gateway_transit        = azurerm_virtual_network_peering.local_to_remote.allow_gateway_transit
      use_remote_gateways          = azurerm_virtual_network_peering.local_to_remote.use_remote_gateways
    }
    remote_to_local = {
      allow_virtual_network_access = azurerm_virtual_network_peering.remote_to_local.allow_virtual_network_access
      allow_forwarded_traffic      = azurerm_virtual_network_peering.remote_to_local.allow_forwarded_traffic
      allow_gateway_transit        = azurerm_virtual_network_peering.remote_to_local.allow_gateway_transit
      use_remote_gateways          = azurerm_virtual_network_peering.remote_to_local.use_remote_gateways
    }
  }
}
