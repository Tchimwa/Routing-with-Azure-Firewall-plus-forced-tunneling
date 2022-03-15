variable "prefix" {
  Type = string
  description = "The prefix which should be used to define the region"
}

variable "spokeAppdressSpace" {
    Type = string
}

variable "spokePrefix" {
    Type = string
}

variable "spokeAddressPrefix" {
    Type = string
}

variable "location" {
  Type = string
  description = "The Azure Region in which all resources in this example should be created."
}

variable "group" {
    Type = string
    description = "Resource group for the cloud environment"
}

variable "username" {
  description = "Administrator username"
  Type = string
}

variable "password" {
  Type = string
  description = "administrator password (recommended to disable password auth)"
}

var "labtags" {
   Type = map(string)
}