variable "local_resource_group_name" {
  type        = string
  description = "Name of the resource group containing the local virtual network."
}

variable "local_vnet_name" {
  type        = string
  description = "Name of the local virtual network."
}

variable "local_vnet_id" {
  type        = string
  description = "Resource ID of the local virtual network."
}

variable "remote_resource_group_name" {
  type        = string
  description = "Name of the resource group containing the remote virtual network."
}

variable "remote_vnet_name" {
  type        = string
  description = "Name of the remote virtual network."
}

variable "remote_vnet_id" {
  type        = string
  description = "Resource ID of the remote virtual network."
}
