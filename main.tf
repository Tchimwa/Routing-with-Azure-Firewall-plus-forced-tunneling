terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}

provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "main" {
  name     = "azcloud-rg"
  location = "eastus"
  tags = {
        Deployment_type  =   "Terraform"
        Project                   =    "LABTIME"
        Environment         =   "Azure"  
   }
}

