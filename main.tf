provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
}

locals {
  normalized_name_prefix = lower(trim(replace(trimspace(var.name_prefix), "/[^0-9A-Za-z]+/", "-"), "-"))
  hub_subnets = {
    shared-services = try(cidrsubnet(var.hub_cidr, 8, 0), var.hub_cidr)
  }
  cidr_inputs_valid_for_hub_spoke_check = try(
    tonumber(split("/", var.hub_cidr)[1]) >= 2 &&
    tonumber(split("/", var.hub_cidr)[1]) <= 21 &&
    can(cidrhost(var.hub_cidr, 0)) &&
    alltrue([
      for spoke in values(var.spokes) :
      tonumber(split("/", spoke.cidr)[1]) >= 2 &&
      tonumber(split("/", spoke.cidr)[1]) <= 29 &&
      can(cidrhost(spoke.cidr, 0))
    ]),
    false
  )
  hub_spoke_cidrs_non_overlapping = !local.cidr_inputs_valid_for_hub_spoke_check || try(alltrue([
    for spoke in values(var.spokes) :
    (
      sum([for index, octet in split(".", cidrhost(var.hub_cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]) + pow(2, 32 - tonumber(split("/", var.hub_cidr)[1])) <=
      sum([for index, octet in split(".", cidrhost(spoke.cidr, 0)) : tonumber(octet) * pow(256, 3 - index)])
      ) || (
      sum([for index, octet in split(".", cidrhost(spoke.cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]) + pow(2, 32 - tonumber(split("/", spoke.cidr)[1])) <=
      sum([for index, octet in split(".", cidrhost(var.hub_cidr, 0)) : tonumber(octet) * pow(256, 3 - index)])
    )
  ]), false)
}

module "network_resource_group" {
  source = "./modules/resource-group"

  name     = "${local.normalized_name_prefix}-network-rg"
  location = var.location
}

module "hub_network" {
  source = "./modules/virtual-network"

  name                = "${local.normalized_name_prefix}-hub-vnet"
  location            = var.location
  resource_group_name = module.network_resource_group.name
  address_space       = [var.hub_cidr]
  subnets             = local.hub_subnets
}

module "spoke_networks" {
  source   = "./modules/virtual-network"
  for_each = var.spokes

  name                = "${local.normalized_name_prefix}-${each.key}-vnet"
  location            = var.location
  resource_group_name = module.network_resource_group.name
  address_space       = [each.value.cidr]
  subnets             = each.value.subnets
}

module "hub_network_security" {
  source = "./modules/network-security"

  name_prefix         = "${local.normalized_name_prefix}-hub"
  location            = var.location
  resource_group_name = module.network_resource_group.name
  subnet_ids          = module.hub_network.subnet_ids
}

module "spoke_network_security" {
  source   = "./modules/network-security"
  for_each = var.spokes

  name_prefix         = "${local.normalized_name_prefix}-${each.key}"
  location            = var.location
  resource_group_name = module.network_resource_group.name
  subnet_ids          = module.spoke_networks[each.key].subnet_ids
}

module "hub_routing" {
  source = "./modules/routing"

  name_prefix         = "${local.normalized_name_prefix}-hub"
  location            = var.location
  resource_group_name = module.network_resource_group.name
  subnet_ids          = module.hub_network.subnet_ids
}

module "spoke_routing" {
  source   = "./modules/routing"
  for_each = var.spokes

  name_prefix         = "${local.normalized_name_prefix}-${each.key}"
  location            = var.location
  resource_group_name = module.network_resource_group.name
  subnet_ids          = module.spoke_networks[each.key].subnet_ids
}

module "hub_spoke_peerings" {
  source   = "./modules/peering"
  for_each = var.spokes

  local_resource_group_name  = module.network_resource_group.name
  local_vnet_name            = module.hub_network.vnet_name
  local_vnet_id              = module.hub_network.vnet_id
  remote_resource_group_name = module.network_resource_group.name
  remote_vnet_name           = module.spoke_networks[each.key].vnet_name
  remote_vnet_id             = module.spoke_networks[each.key].vnet_id
}
