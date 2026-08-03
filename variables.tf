variable "location" {
  type        = string
  description = "Azure region for all reference resources."
  default     = "eastus"

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "name_prefix" {
  type        = string
  description = "Human-readable prefix normalized into Azure resource names by the root module."
  default     = "contoso-platform"

  validation {
    condition     = length(trimspace(var.name_prefix)) > 0 && can(regex("[[:alnum:]]", var.name_prefix))
    error_message = "name_prefix must contain at least one letter or number."
  }
}

variable "hub_cidr" {
  type        = string
  description = "IPv4 CIDR assigned to the hub virtual network."
  default     = "10.10.0.0/16"

  validation {
    condition = try(
      var.hub_cidr == trimspace(var.hub_cidr) &&
      length(var.hub_cidr) > 0 &&
      can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}/([0-9]|[12][0-9]|3[0-2])$", var.hub_cidr)) &&
      can(cidrhost(var.hub_cidr, 0)) &&
      tonumber(split("/", var.hub_cidr)[1]) >= 2 &&
      tonumber(split("/", var.hub_cidr)[1]) <= 21,
      false
    )
    error_message = "hub_cidr must be a non-empty, trimmed, valid IPv4 CIDR with a prefix length from /2 through /21 so the derived hub subnet is no narrower than Azure's /29 limit."
  }
}

variable "spokes" {
  type = map(object({
    cidr    = string
    subnets = map(string)
  }))
  description = "Stable spoke keys, each with one IPv4 VNet CIDR and a map of IPv4 subnet CIDRs."
  default = {
    app = {
      cidr = "10.20.0.0/16"
      subnets = {
        application = "10.20.1.0/24"
      }
    }
    data = {
      cidr = "10.30.0.0/16"
      subnets = {
        data = "10.30.1.0/24"
      }
    }
  }

  validation {
    condition = length(var.spokes) > 0 && alltrue([
      for spoke in values(var.spokes) :
      try(
        spoke.cidr == trimspace(spoke.cidr) &&
        length(spoke.cidr) > 0 &&
        can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}/([0-9]|[12][0-9]|3[0-2])$", spoke.cidr)) &&
        can(cidrhost(spoke.cidr, 0)) &&
        tonumber(split("/", spoke.cidr)[1]) >= 2 &&
        tonumber(split("/", spoke.cidr)[1]) <= 29 &&
        length(spoke.subnets) > 0 &&
        alltrue([
          for subnet_cidr in values(spoke.subnets) :
          subnet_cidr == trimspace(subnet_cidr) &&
          length(subnet_cidr) > 0 &&
          can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}/([0-9]|[12][0-9]|3[0-2])$", subnet_cidr)) &&
          can(cidrhost(subnet_cidr, 0)) &&
          tonumber(split("/", subnet_cidr)[1]) >= 2 &&
          tonumber(split("/", subnet_cidr)[1]) <= 29
        ]),
        false
      )
    ])
    error_message = "spokes must be non-empty; every spoke must define at least one subnet; and each spoke and subnet CIDR must be non-empty, trimmed, valid IPv4 with a prefix length from /2 through /29."
  }

  validation {
    condition = alltrue(flatten([
      for outer_key, outer_spoke in var.spokes : [
        for inner_key, inner_spoke in var.spokes :
        outer_key == inner_key ? true : try(
          (
            sum([for index, octet in split(".", cidrhost(outer_spoke.cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]) + pow(2, 32 - tonumber(split("/", outer_spoke.cidr)[1])) <=
            sum([for index, octet in split(".", cidrhost(inner_spoke.cidr, 0)) : tonumber(octet) * pow(256, 3 - index)])
            ) || (
            sum([for index, octet in split(".", cidrhost(inner_spoke.cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]) + pow(2, 32 - tonumber(split("/", inner_spoke.cidr)[1])) <=
            sum([for index, octet in split(".", cidrhost(outer_spoke.cidr, 0)) : tonumber(octet) * pow(256, 3 - index)])
          ),
          false
        )
      ]
      ])) && alltrue(flatten([
      for spoke in values(var.spokes) : [
        for subnet_cidr in values(spoke.subnets) :
        try(
          sum([for index, octet in split(".", cidrhost(spoke.cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]) <=
          sum([for index, octet in split(".", cidrhost(subnet_cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]) &&
          sum([for index, octet in split(".", cidrhost(subnet_cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]) + pow(2, 32 - tonumber(split("/", subnet_cidr)[1])) <=
          sum([for index, octet in split(".", cidrhost(spoke.cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]) + pow(2, 32 - tonumber(split("/", spoke.cidr)[1])),
          false
        )
      ]
      ])) && alltrue(flatten([
      for spoke in values(var.spokes) : flatten([
        for outer_key, outer_subnet_cidr in spoke.subnets : [
          for inner_key, inner_subnet_cidr in spoke.subnets :
          outer_key == inner_key ? true : try(
            (
              sum([for index, octet in split(".", cidrhost(outer_subnet_cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]) + pow(2, 32 - tonumber(split("/", outer_subnet_cidr)[1])) <=
              sum([for index, octet in split(".", cidrhost(inner_subnet_cidr, 0)) : tonumber(octet) * pow(256, 3 - index)])
              ) || (
              sum([for index, octet in split(".", cidrhost(inner_subnet_cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]) + pow(2, 32 - tonumber(split("/", inner_subnet_cidr)[1])) <=
              sum([for index, octet in split(".", cidrhost(outer_subnet_cidr, 0)) : tonumber(octet) * pow(256, 3 - index)])
            ),
            false
          )
        ]
      ])
    ]))
    error_message = "Spoke CIDRs must not overlap; every subnet CIDR must be contained within its parent spoke CIDR; and sibling subnet CIDRs within a spoke must not overlap."
  }
}
