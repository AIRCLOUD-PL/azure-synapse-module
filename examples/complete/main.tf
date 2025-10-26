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
  name     = "rg-synapse-complete-example"
  location = "westeurope"
}

resource "azurerm_storage_account" "example" {
  name                     = "stsynapsecomplete001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "example" {
  name               = "synapse"
  storage_account_id = azurerm_storage_account.example.id
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-synapse-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "database" {
  name                 = "snet-database"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "development" {
  name                 = "snet-development"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_private_dns_zone" "synapse_sql" {
  name                = "privatelink.sql.azuresynapse.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "synapse_dev" {
  name                = "privatelink.dev.azuresynapse.net"
  resource_group_name = azurerm_resource_group.example.name
}

module "synapse" {
  source = "../.."

  synapse_workspace_name               = "synapse-complete-example"
  location                             = azurerm_resource_group.example.location
  resource_group_name                  = azurerm_resource_group.example.name
  environment                          = "test"
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.example.id
  sql_administrator_login              = "sqladmin"
  sql_administrator_login_password     = "P@ssw0rd123!"

  # Security
  managed_virtual_network_enabled      = true
  data_exfiltration_protection_enabled = true
  public_network_access_enabled        = false
  azuread_authentication_only          = true
  identity_type                        = "SystemAssigned"

  # Git integration
  github_repo = {
    account_name    = "AIRCLOUD-PL"
    branch_name     = "main"
    repository_name = "synapse-analytics"
    root_folder     = "/"
  }

  # Security features
  enable_security_alert_policy    = true
  enable_vulnerability_assessment = true
  enable_extended_auditing_policy = true

  # Dedicated SQL Pools
  dedicated_sql_pools = {
    "datawarehouse" = {
      sku_name                  = "DW1000c"
      geo_backup_policy_enabled = true
      data_encrypted            = true
    }
  }

  # Spark Pools
  spark_pools = {
    "sparkpool" = {
      node_size_family = "MemoryOptimized"
      node_size        = "Large"
      node_count       = 5

      auto_scale = {
        max_node_count = 10
        min_node_count = 3
      }

      auto_pause = {
        delay_in_minutes = 15
      }

      spark_version = "3.2"
    }
  }

  # Private Endpoints
  private_endpoints = {
    synapse_sql = {
      subnet_id = azurerm_subnet.database.id
      private_dns_zone_ids = [
        azurerm_private_dns_zone.synapse_sql.id
      ]
    }

    synapse_dev = {
      subnet_id = azurerm_subnet.development.id
      private_dns_zone_ids = [
        azurerm_private_dns_zone.synapse_dev.id
      ]
    }
  }

  # Firewall Rules (for maintenance)
  firewall_rules = {
    "azure-services" = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  }

  tags = {
    Example = "Complete"
  }
}

output "synapse_workspace_id" {
  value = module.synapse.synapse_workspace_id
}

output "synapse_workspace_name" {
  value = module.synapse.synapse_workspace_name
}

output "synapse_workspace_connectivity_endpoints" {
  value = module.synapse.synapse_workspace_connectivity_endpoints
}

output "dedicated_sql_pools" {
  value = module.synapse.dedicated_sql_pools
}

output "spark_pools" {
  value = module.synapse.spark_pools
}

output "identity_principal_id" {
  value = module.synapse.identity_principal_id
}