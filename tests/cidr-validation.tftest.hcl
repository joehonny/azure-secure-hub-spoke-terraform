mock_provider "azurerm" {}

run "accepts_hub_prefix_21_boundary" {
  command = plan

  variables {
    hub_cidr = "10.10.0.0/21"
  }

  assert {
    condition     = local.hub_subnets["shared-services"] == "10.10.0.0/29"
    error_message = "A hub /21 must derive an Azure-supported /29 shared-services subnet."
  }
}

run "rejects_hub_prefix_0" {
  command = plan

  variables {
    hub_cidr = "0.0.0.0/0"
  }

  expect_failures = [var.hub_cidr]
}

run "rejects_hub_prefix_1" {
  command = plan

  variables {
    hub_cidr = "0.0.0.0/1"
  }

  expect_failures = [var.hub_cidr]
}

run "rejects_hub_prefix_22" {
  command = plan

  variables {
    hub_cidr = "10.10.0.0/22"
  }

  expect_failures = [var.hub_cidr]
}

run "rejects_hub_prefix_25" {
  command = plan

  variables {
    hub_cidr = "10.10.0.0/25"
  }

  expect_failures = [var.hub_cidr]
}

run "rejects_spoke_prefix_30" {
  command = plan

  variables {
    spokes = {
      app = {
        cidr = "10.20.0.0/30"
        subnets = {
          application = "10.20.0.0/30"
        }
      }
    }
  }

  expect_failures = [var.spokes]
}

run "rejects_spoke_prefix_31" {
  command = plan

  variables {
    spokes = {
      app = {
        cidr = "10.20.0.0/31"
        subnets = {
          application = "10.20.0.0/31"
        }
      }
    }
  }

  expect_failures = [var.spokes]
}

run "rejects_spoke_prefix_32" {
  command = plan

  variables {
    spokes = {
      app = {
        cidr = "10.20.0.0/32"
        subnets = {
          application = "10.20.0.0/32"
        }
      }
    }
  }

  expect_failures = [var.spokes]
}

run "rejects_subnet_prefix_30" {
  command = plan

  variables {
    spokes = {
      app = {
        cidr = "10.20.0.0/16"
        subnets = {
          application = "10.20.1.0/30"
        }
      }
    }
  }

  expect_failures = [var.spokes]
}

run "rejects_subnet_prefix_31" {
  command = plan

  variables {
    spokes = {
      app = {
        cidr = "10.20.0.0/16"
        subnets = {
          application = "10.20.1.0/31"
        }
      }
    }
  }

  expect_failures = [var.spokes]
}

run "rejects_subnet_prefix_32" {
  command = plan

  variables {
    spokes = {
      app = {
        cidr = "10.20.0.0/16"
        subnets = {
          application = "10.20.1.1/32"
        }
      }
    }
  }

  expect_failures = [var.spokes]
}

run "rejects_hub_spoke_overlap" {
  command = plan

  variables {
    spokes = {
      app = {
        cidr = "10.10.0.0/20"
        subnets = {
          application = "10.10.1.0/24"
        }
      }
    }
  }

  expect_failures = [output.hub_vnet_id]
}

run "rejects_subnet_outside_parent_spoke" {
  command = plan

  variables {
    spokes = {
      app = {
        cidr = "10.20.0.0/16"
        subnets = {
          application = "10.30.1.0/24"
        }
      }
    }
  }

  expect_failures = [var.spokes]
}

run "rejects_overlapping_sibling_subnets" {
  command = plan

  variables {
    spokes = {
      app = {
        cidr = "10.20.0.0/16"
        subnets = {
          application = "10.20.1.0/24"
          services    = "10.20.1.128/25"
        }
      }
    }
  }

  expect_failures = [var.spokes]
}
