# Reference-only validation example. This is not a deployed production environment.
terraform {
  required_version = ">= 1.7.0"
}

module "hub_spoke_reference" {
  source = "../.."

  location    = "eastus"
  name_prefix = "contoso-reference"
  hub_cidr    = "10.100.0.0/16"

  spokes = {
    app = {
      cidr = "10.110.0.0/16"
      subnets = {
        application = "10.110.1.0/24"
      }
    }
    data = {
      cidr = "10.120.0.0/16"
      subnets = {
        data = "10.120.1.0/24"
      }
    }
  }
}

output "reference_hub_vnet_id" {
  description = "Resource ID of the reference-only hub virtual network."
  value       = module.hub_spoke_reference.hub_vnet_id
}
