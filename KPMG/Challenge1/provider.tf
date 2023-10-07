terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.44.1"
    }
  }
  backend "azurerm" {
    storage_account_name = "azdevsa"
    container_name       = "azdevcontainer"
    key                  = "az-dev.tfstate"
    use_azuread_auth     = true
    subscription_id      = ""
    tenant_id            = ""
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}