# Azure Synapse Analytics Terraform Module

Enterprise-grade Azure Synapse Analytics module with comprehensive security, compliance, and performance features.

## Features

✅ **Unified Analytics** - SQL pools, Spark pools, data integration  
✅ **Advanced Security** - Customer-managed keys, private endpoints, threat protection  
✅ **Managed Virtual Network** - Secure network isolation, data exfiltration protection  
✅ **Data Lake Integration** - Native integration with ADLS Gen2  
✅ **Git Integration** - Source control for notebooks and pipelines  
✅ **Performance** - Auto-scaling, auto-pause, optimized resource usage  
✅ **Compliance** - Azure Policy integration, audit logging  
✅ **Identity** - Azure AD authentication, managed identities  

## Usage

### Basic Example

```hcl
module "synapse" {
  source = "github.com/AIRCLOUD-PL/terraform-azurerm-synapse-analytics?ref=v1.0.0"

  synapse_workspace_name              = "synapse-prod-westeurope-001"
  location                          = "westeurope"
  resource_group_name               = "rg-production"
  environment                       = "prod"
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.main.id
  sql_administrator_login           = "sqladmin"
  sql_administrator_login_password  = "P@ssw0rd123!"

  tags = {
    Environment = "Production"
  }
}
```

### Complete Example with Security

```hcl
module "synapse" {
  source = "github.com/AIRCLOUD-PL/terraform-azurerm-synapse-analytics?ref=v1.0.0"

  synapse_workspace_name              = "synapse-prod-westeurope-001"
  location                          = "westeurope"
  resource_group_name               = "rg-production"
  environment                       = "prod"
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.main.id
  sql_administrator_login           = "sqladmin"
  sql_administrator_login_password  = "P@ssw0rd123!"

  # Security
  managed_virtual_network_enabled      = true
  data_exfiltration_protection_enabled = true
  public_network_access_enabled        = false
  azuread_authentication_only          = true
  identity_type                        = "SystemAssigned"

  # Customer-managed encryption
  customer_managed_key = {
    key_versionless_id = azurerm_key_vault_key.synapse.id
  }

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
      sku_name = "DW1000c"
      geo_backup_policy_enabled = true
      data_encrypted           = true
    }

    "reporting" = {
      sku_name = "DW500c"
      geo_backup_policy_enabled = true
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

    "smallpool" = {
      node_size_family = "MemoryOptimized"
      node_size        = "Small"
      node_count       = 3

      auto_pause = {
        delay_in_minutes = 30
      }
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

    synapse_sql_on_demand = {
      subnet_id = azurerm_subnet.database.id
      private_dns_zone_ids = [
        azurerm_private_dns_zone.synapse_sqlod.id
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
    Environment = "Production"
    DataClass   = "Confidential"
    Compliance  = "SOX"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.80.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.80.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Azure region | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| storage_data_lake_gen2_filesystem_id | Data Lake filesystem ID | `string` | n/a | yes |
| sql_administrator_login | SQL admin login | `string` | n/a | yes |
| sql_administrator_login_password | SQL admin password | `string` | n/a | yes |
| dedicated_sql_pools | Dedicated SQL pools config | `map(object)` | `{}` | no |
| spark_pools | Spark pools config | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| synapse_workspace_id | Synapse workspace ID |
| synapse_workspace_name | Synapse workspace name |
| dedicated_sql_pools | Dedicated SQL pools |
| spark_pools | Spark pools |

## Examples

- [Basic](./examples/basic/) - Simple Synapse workspace
- [Complete](./examples/complete/) - Full enterprise features

## Security Features

### Data Protection
- **Customer-Managed Keys** - Full encryption control
- **Advanced Threat Protection** - Real-time security monitoring
- **Data Exfiltration Protection** - Prevent data leakage
- **Private Endpoints** - Secure private connectivity

### Network Security
- **Managed Virtual Network** - Network isolation
- **VNet Integration** - Secure network access
- **Firewall Rules** - Granular access control
- **IP Filtering** - Network-level security

### High Availability
- **Geo-Redundancy** - Cross-region replication
- **Automatic Failover** - Zero-downtime failover
- **Backup & Recovery** - Point-in-time restore
- **Disaster Recovery** - Business continuity

### Compliance & Governance
- **Azure Policy** - Automated compliance
- **Audit Logging** - Comprehensive audit trails
- **Resource Locks** - Prevent accidental deletion
- **Azure AD Integration** - Modern authentication

## Version

Current version: **v1.0.0**

## License

MIT