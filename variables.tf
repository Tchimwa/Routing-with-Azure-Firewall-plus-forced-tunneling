variable "Prefix" {
  Type = list(string)
  default = ["eastus", "westus"]
  description = "The prefix which should be used for all resources in this example"
}

variable "SpokeAppdressSpace" {
    Type = list (string)
    default = ["10.120.0.0/16", "10.220.0.0/16"]
}

variable "SpokeAddressPrefix" {
    Type = list(string)
    default = ["10.120.0.0/24", "10.220.0.0/24"]
}

variable "SpokePrefix" {
    Type = list (string)
    default = ["10.120.0", "10.220.0"]
}    