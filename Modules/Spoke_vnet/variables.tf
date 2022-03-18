variable "prefix" {
  type        = string
  description = "The prefix which should be used to define the region"
}

variable "spokeAddressSpace" {
  type = string
}

variable "spokePrefix" {
  type = string
}

variable "spokeAddressPrefix" {
  type = string
}

variable "location" {
  type        = string
  description = "The Azure Region in which all resources in this example should be created."
}

variable "group" {
  type        = string
  description = "Resource group for the cloud environment"
}

variable "username" {
  description = "Administrator username"
  type        = string
}

variable "password" {
  type        = string
  description = "administrator password (recommended to disable password auth)"
}

variable "labtags" {
  type = map(string)
}