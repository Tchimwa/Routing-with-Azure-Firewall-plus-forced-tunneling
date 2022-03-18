variable "Peered_loc" {
  type    = string
  default = "westus"
}
variable "Prefix" {
  type        = list(string)
  default     = ["westus", "eastus"]
  description = "The prefix which should be used for all resources in this example"
}

variable "SpokeAddressSpace" {
  type    = list(string)
  default = ["10.120.0.0/16", "10.220.0.0/16"]
}

variable "SpokeAddressPrefix" {
  type    = list(string)
  default = ["10.120.0.0/24", "10.220.0.0/24"]
}

variable "SpokePrefix" {
  type    = list(string)
  default = ["10.120.0", "10.220.0"]
}
variable "AppAddressSpace" {
  type    = list(string)
  default = ["10.110.0.0/16", "10.210.0.0/16"]
}

variable "AppPrefix" {
  type    = list(string)
  default = ["10.110.0", "10.210.0"]
}

variable "AppAddressPrefix" {
  type    = list(string)
  default = ["10.110.0.0/24", "10.210.0.0/24"]
}

variable "BackendAddressPrefix" {
  type    = list(string)
  default = ["10.110.1.0/24", "10.210.1.0/24"]
}

variable "HubAddressSpace" {
  type = list(string)
  default = ["10.100.0.0/16", "10.200.0.0/16"]
}

variable "HubgwAddressPrefix" {
  type = list(string)
  default = ["10.100.0.0/24", "10.200.0.0/24"]
}

variable "HubbstAddressPrefix" {
  type = list(string)
  default = ["10.100.1.0/24", "10.200.1.0/24"]
}

variable "HubfwAddressPrefix" {
  type = list(string)
  default = ["10.100.2.0/24", "10.200.2.0/24"]
}

variable "HubfwmgmtAddressPrefix" {
  type = list(string)
  default = ["10.100.3.0/24", "10.200.3.0/24"]
}

variable "HubappsAddressPrefix" {
  type = list(string)
  default = ["10.100.4.0/24", "10.200.4.0/24"]
}

variable "HubsrvAddressPrefix" {
  type = list(string)
  default = ["10.100.5.0/24", "10.200.5.0/24"]
}

variable "BgpAsn" {
  type = list(string)
  default = ["65010", "65020"]
}

variable "HubappsPrefix" {
  type = list(string)
  default = ["10.100.4", "10.200.4"]
}

variable "HubsrvPrefix" {
  type = list(string)
  default = ["10.100.5", "10.200.5"]
}

variable "Username" {
  type    = string
  default = "netdata"
}

variable "Password" {
  type    = string
  default = "Networking2022#"
}
