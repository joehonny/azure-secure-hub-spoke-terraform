variable "name" {
  type        = string
  description = "Name of the virtual network."
}

variable "location" {
  type        = string
  description = "Azure region for the virtual network."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group containing the virtual network."
}

variable "address_space" {
  type        = list(string)
  description = "IPv4 address spaces assigned to the virtual network."
}

variable "subnets" {
  type        = map(string)
  description = "Stable subnet keys mapped to IPv4 CIDRs."
}
