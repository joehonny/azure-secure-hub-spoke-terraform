output "hub_vnet_id" {
  description = "Resource ID of the hub virtual network."
  value       = module.hub_network.vnet_id

  precondition {
    condition     = local.hub_spoke_cidrs_non_overlapping
    error_message = "hub_cidr must not overlap any spoke CIDR."
  }
}

output "spoke_vnet_ids" {
  description = "Map of stable spoke keys to their virtual network resource IDs."
  value = {
    for spoke_key, network in module.spoke_networks :
    spoke_key => network.vnet_id
  }
}

output "subnet_ids" {
  description = "Nested map of hub and stable spoke keys to subnet resource IDs."
  value = {
    hub = module.hub_network.subnet_ids
    spokes = {
      for spoke_key, network in module.spoke_networks :
      spoke_key => network.subnet_ids
    }
  }
}
