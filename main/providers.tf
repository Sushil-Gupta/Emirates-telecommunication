terraform {
  required_version = "~> 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.74" #, < 5.0.0" #"~> 3.74"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

}

provider "azurerm" {
  subscription_id = var.subscription_id
  # As Azure policy blocks the use of shared keys for storage accounts, we need to use Azure AD authentication for any data plane operations.
  storage_use_azuread = true


  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}