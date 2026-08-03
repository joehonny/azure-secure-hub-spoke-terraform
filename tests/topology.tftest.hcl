mock_provider "azurerm" {}

run "builds_the_default_network_topology" {
  command = plan

  assert {
    condition     = module.network_resource_group.name == "contoso-platform-network-rg"
    error_message = "The default topology must contain the deterministic network resource group."
  }

  assert {
    condition     = 1 + length(module.spoke_networks) == 3
    error_message = "The default topology must contain one hub and two spoke virtual networks."
  }

  assert {
    condition = length(module.hub_network.subnet_ids) + sum([
      for network in values(module.spoke_networks) : length(network.subnet_ids)
    ]) == 3
    error_message = "The default topology must contain one hub subnet and two spoke subnets."
  }

  assert {
    condition = length(module.hub_network_security.network_security_group_ids) + sum([
      for security in values(module.spoke_network_security) : length(security.network_security_group_ids)
    ]) == 3
    error_message = "The default topology must contain one network security group per subnet."
  }

  assert {
    condition = length(module.hub_network_security.subnet_associations) + sum([
      for security in values(module.spoke_network_security) : length(security.subnet_associations)
    ]) == 3
    error_message = "The default topology must contain one network security group association per subnet."
  }

  assert {
    condition = (
      toset(keys(module.hub_network_security.subnet_associations)) == toset(keys(module.hub_network.subnet_ids)) &&
      toset(keys(module.hub_network_security.subnet_associations)) == toset(keys(module.hub_network_security.network_security_group_ids)) &&
      alltrue([
        for spoke_key, security in module.spoke_network_security :
        toset(keys(security.subnet_associations)) == toset(keys(module.spoke_networks[spoke_key].subnet_ids)) &&
        toset(keys(security.subnet_associations)) == toset(keys(security.network_security_group_ids))
      ])
    )
    error_message = "Every default subnet must be associated with its stable-key network security group."
  }

  assert {
    condition = length(module.hub_routing.route_table_ids) + sum([
      for routing in values(module.spoke_routing) : length(routing.route_table_ids)
    ]) == 3
    error_message = "The default topology must contain one route table per subnet."
  }

  assert {
    condition = length(module.hub_routing.subnet_associations) + sum([
      for routing in values(module.spoke_routing) : length(routing.subnet_associations)
    ]) == 3
    error_message = "The default topology must contain one route table association per subnet."
  }

  assert {
    condition = (
      toset(keys(module.hub_routing.subnet_associations)) == toset(keys(module.hub_network.subnet_ids)) &&
      toset(keys(module.hub_routing.subnet_associations)) == toset(keys(module.hub_routing.route_table_ids)) &&
      alltrue([
        for spoke_key, routing in module.spoke_routing :
        toset(keys(routing.subnet_associations)) == toset(keys(module.spoke_networks[spoke_key].subnet_ids)) &&
        toset(keys(routing.subnet_associations)) == toset(keys(routing.route_table_ids))
      ])
    )
    error_message = "Every default subnet must be associated with its stable-key route table."
  }

  assert {
    condition = toset(keys(module.hub_spoke_peerings)) == toset(["app", "data"]) && alltrue([
      for peering in values(module.hub_spoke_peerings) :
      toset(keys(peering.peering_ids)) == toset(["local_to_remote", "remote_to_local"])
    ])
    error_message = "Both peering directions must exist for both stable spoke keys."
  }

  assert {
    condition = sum([
      for peering in values(module.hub_spoke_peerings) : length(peering.peering_ids)
    ]) == 4
    error_message = "The default topology must contain four virtual network peering resources."
  }

  assert {
    condition = alltrue(flatten([
      for peering in values(module.hub_spoke_peerings) : [
        for settings in values(peering.peering_settings) :
        settings.allow_virtual_network_access &&
        !settings.allow_forwarded_traffic &&
        !settings.allow_gateway_transit &&
        !settings.use_remote_gateways
      ]
    ]))
    error_message = "Every peering direction must allow direct VNet access while disabling forwarded traffic and gateway transit."
  }
}
