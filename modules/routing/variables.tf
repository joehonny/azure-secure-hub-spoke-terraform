variable "name_prefix" {
  type        = string
  description = "Normalized prefix used for route table names."
}

variable "location" {
  type        = string
  description = "Azure region for the route tables."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group containing the route tables."
}

variable "subnet_ids" {
  type        = map(string)
  description = "Map of stable subnet keys to subnet resource IDs."
}
