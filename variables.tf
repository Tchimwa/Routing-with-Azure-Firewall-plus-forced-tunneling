variable "Prefix" {
  type        = list(string)
  default     = ["westus", "eastus"]
  description = "The prefix which should be used for all resources in this example"
}

variable "SpokeAppdressSpace" {
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

variable "Subscription_id" {
  type = string
}

variable "Client_id" {
  type = string
}

variable "Client_secret" {
  type = string
}

variable "Tenant_id" {
  type = string
}