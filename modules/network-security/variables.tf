variable "name_prefix" {
  type        = string
  description = "Normalized prefix used for network security group names."
}

variable "location" {
  type        = string
  description = "Azure region for the network security groups."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group containing the network security groups."
}

variable "subnet_ids" {
  type        = map(string)
  description = "Map of stable subnet keys to subnet resource IDs."
}
