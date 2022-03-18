variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "group" {
  type = string
}

variable "hubAddressSpace" {
  type = string
}

variable "hubgwAddressPrefix" {
  type = string
}

variable "hubbstAddressPrefix" {
  type = string
}

variable "hubfwAddressPrefix" {
  type = string
}

variable "hubfwmgmtAddressPrefix" {
  type = string
}

variable "hubappsAddressPrefix" {
  type = string
}

variable "hubsrvAddressPrefix" {
  type = string
}

variable "bgpasn" {
  type = string
}

variable "hubappsPrefix" {
  type = string
}

variable "hubsrvPrefix" {
  type = string
}

variable "username" {
  description = "Administrator username"
  type        = string
}

variable "password" {
  type = string
}

variable "labtags" {
  type = map(string)
}