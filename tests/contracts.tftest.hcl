mock_provider "azurerm" {}

run "normalizes_the_network_name_prefix" {
  command = plan

  variables {
    location    = "eastus"
    name_prefix = "Contoso Platform"
    hub_cidr    = "10.10.0.0/16"
    spokes = {
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
  }

  assert {
    condition     = local.normalized_name_prefix == "contoso-platform"
    error_message = "Network names must normalize the prefix to lowercase hyphenated text."
  }
}

run "preserves_stable_spoke_keys" {
  command = plan

  variables {
    location    = "eastus"
    name_prefix = "Contoso Platform"
    hub_cidr    = "10.10.0.0/16"
    spokes = {
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
  }

  assert {
    condition     = toset(keys(output.spoke_vnet_ids)) == toset(["app", "data"])
    error_message = "Spoke VNet IDs must retain the app and data map keys."
  }

  assert {
    condition     = toset(keys(output.subnet_ids.spokes)) == toset(["app", "data"])
    error_message = "Subnet IDs must retain the app and data parent map keys."
  }
}
