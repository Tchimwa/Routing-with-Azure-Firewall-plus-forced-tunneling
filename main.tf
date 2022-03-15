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

  subscription_id = "10d33b0d-f927-45f4-a5a2-dd2ef6a282eb"
  client_id = "f39e37ef-9337-4ad4-b985-36aabd6716bf"
  client_secret = "rydrKrAnz9WudNnAaiHoH3KXSX-G09lTyo"
  tenant_id = "72f988bf-86f1-41af-91ab-2d7cd011db47"
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

