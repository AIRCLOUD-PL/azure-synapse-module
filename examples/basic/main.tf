terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-synapse-basic-example"
  location = "westeurope"
}

resource "azurerm_storage_account" "example" {
  name                     = "stsynapsebasic001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
}

resource "azurerm_storage_data_lake_gen2_filesystem" "example" {
  name               = "synapse"
  storage_account_id = azurerm_storage_account.example.id
}

module "synapse" {
  source = "../.."

  synapse_workspace_name               = "synapse-basic-example"
  location                             = azurerm_resource_group.example.location
  resource_group_name                  = azurerm_resource_group.example.name
  environment                          = "test"
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.example.id
  sql_administrator_login              = "sqladmin"
  sql_administrator_login_password     = "P@ssw0rd123!"

  tags = {
    Example = "Basic"
  }
}

output "synapse_workspace_name" {
  value = module.synapse.synapse_workspace_name
}

output "synapse_workspace_connectivity_endpoints" {
  value = module.synapse.synapse_workspace_connectivity_endpoints
}