<p align="center">
  <a href="https://aircloud.com.pl"><img src=".github/assets/banner.png" alt="AIRCLOUD: DevOps, cloud and AI engineering" width="100%"></a>
</p>

# azure-synapse-module

**Azure Synapse Analytics Terraform module — parameterised, azurerm 4.x, CI-validated.**

[![CI](https://github.com/AIRCLOUD-PL/azure-synapse-module/actions/workflows/ci.yml/badge.svg)](https://github.com/AIRCLOUD-PL/azure-synapse-module/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/AIRCLOUD-PL/azure-synapse-module?sort=semver)](https://github.com/AIRCLOUD-PL/azure-synapse-module/releases)

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

Pin the module to a release tag:

```hcl
module "synapse" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-synapse-module.git?ref=v1.0.0"

  # required inputs
  environment                          = "..."
  location                             = "..."
  resource_group_name                  = "..."
  storage_data_lake_gen2_filesystem_id = "..."
}
```

All inputs and outputs are listed in the generated reference below ([Inputs](#inputs), [Outputs](#outputs)). Worked examples live in [`examples/`](examples/).

### Basic Example

```hcl
module "synapse" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-synapse-module.git?ref=v1.0.0"

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
  source = "git::https://github.com/AIRCLOUD-PL/azure-synapse-module.git?ref=v1.0.0"

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

## Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.synapse_dev](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.synapse_sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.synapse_sql_on_demand](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group_policy_assignment.synapse_auditing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.synapse_data_exfiltration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.synapse_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.synapse_managed_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.synapse_threat_detection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_synapse_firewall_rule.firewall_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_firewall_rule) | resource |
| [azurerm_synapse_spark_pool.pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool) | resource |
| [azurerm_synapse_sql_pool.dedicated_pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_sql_pool) | resource |
| [azurerm_synapse_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace) | resource |
| [azurerm_synapse_workspace_extended_auditing_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_extended_auditing_policy) | resource |
| [azurerm_synapse_workspace_security_alert_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_security_alert_policy) | resource |
| [azurerm_synapse_workspace_vulnerability_assessment.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_vulnerability_assessment) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auditing_policy_retention_in_days"></a> [auditing\_policy\_retention\_in\_days](#input\_auditing\_policy\_retention\_in\_days) | Retention days for auditing logs | `number` | `30` | no |
| <a name="input_auditing_policy_storage_account_access_key"></a> [auditing\_policy\_storage\_account\_access\_key](#input\_auditing\_policy\_storage\_account\_access\_key) | Storage account access key for auditing | `string` | `null` | no |
| <a name="input_auditing_policy_storage_endpoint"></a> [auditing\_policy\_storage\_endpoint](#input\_auditing\_policy\_storage\_endpoint) | Storage endpoint for auditing policy | `string` | `null` | no |
| <a name="input_azuread_authentication_only"></a> [azuread\_authentication\_only](#input\_azuread\_authentication\_only) | Enable Azure AD authentication only | `bool` | `false` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer managed key configuration | <pre>object({<br/>    key_versionless_id = string<br/>  })</pre> | `null` | no |
| <a name="input_data_exfiltration_protection_enabled"></a> [data\_exfiltration\_protection\_enabled](#input\_data\_exfiltration\_protection\_enabled) | Enable data exfiltration protection | `bool` | `true` | no |
| <a name="input_dedicated_sql_pools"></a> [dedicated\_sql\_pools](#input\_dedicated\_sql\_pools) | Dedicated SQL pools configuration | <pre>map(object({<br/>    sku_name             = string<br/>    storage_account_type = optional(string, "GRS")<br/>    create_mode          = optional(string, "Default")<br/>    recovery_database_id = optional(string)<br/>    restore = optional(object({<br/>      source_database_id = string<br/>      point_in_time      = string<br/>    }))<br/>    geo_backup_policy_enabled = optional(bool, true)<br/>    data_encrypted            = optional(bool, true)<br/>    collation                 = optional(string, "SQL_Latin1_General_CP1_CI_AS")<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_extended_auditing_policy"></a> [enable\_extended\_auditing\_policy](#input\_enable\_extended\_auditing\_policy) | Enable extended auditing policy | `bool` | `true` | no |
| <a name="input_enable_policy_assignments"></a> [enable\_policy\_assignments](#input\_enable\_policy\_assignments) | Enable Azure Policy assignments for this Synapse workspace | `bool` | `true` | no |
| <a name="input_enable_security_alert_policy"></a> [enable\_security\_alert\_policy](#input\_enable\_security\_alert\_policy) | Enable security alert policy | `bool` | `true` | no |
| <a name="input_enable_vulnerability_assessment"></a> [enable\_vulnerability\_assessment](#input\_enable\_vulnerability\_assessment) | Enable vulnerability assessment | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., prod, dev, test) | `string` | n/a | yes |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Firewall rules configuration | <pre>map(object({<br/>    start_ip_address = string<br/>    end_ip_address   = string<br/>  }))</pre> | `{}` | no |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | GitHub repository configuration | <pre>object({<br/>    account_name    = string<br/>    branch_name     = string<br/>    repository_name = string<br/>    root_folder     = optional(string, "/")<br/>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of User Assigned Identity IDs | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Type of Managed Identity | `string` | `"SystemAssigned"` | no |
| <a name="input_linking_allowed_for_aad_tenant_ids"></a> [linking\_allowed\_for\_aad\_tenant\_ids](#input\_linking\_allowed\_for\_aad\_tenant\_ids) | List of AAD tenant IDs allowed for linking | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_managed_resource_group_name"></a> [managed\_resource\_group\_name](#input\_managed\_resource\_group\_name) | Name of the managed resource group | `string` | `null` | no |
| <a name="input_managed_virtual_network_enabled"></a> [managed\_virtual\_network\_enabled](#input\_managed\_virtual\_network\_enabled) | Enable managed virtual network | `bool` | `true` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for Synapse naming | `string` | `"synapse"` | no |
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | Private endpoint configurations | <pre>object({<br/>    synapse_sql = optional(object({<br/>      subnet_id            = string<br/>      private_dns_zone_ids = optional(list(string))<br/>    }))<br/>    synapse_sql_on_demand = optional(object({<br/>      subnet_id            = string<br/>      private_dns_zone_ids = optional(list(string))<br/>    }))<br/>    synapse_dev = optional(object({<br/>      subnet_id            = string<br/>      private_dns_zone_ids = optional(list(string))<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Enable public network access | `bool` | `false` | no |
| <a name="input_purview_id"></a> [purview\_id](#input\_purview\_id) | Purview resource ID for integration | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_security_alert_policy_disabled_alerts"></a> [security\_alert\_policy\_disabled\_alerts](#input\_security\_alert\_policy\_disabled\_alerts) | Disabled alerts for security policy | `list(string)` | `[]` | no |
| <a name="input_security_alert_policy_email_account_admins"></a> [security\_alert\_policy\_email\_account\_admins](#input\_security\_alert\_policy\_email\_account\_admins) | Email account admins for security alerts | `bool` | `true` | no |
| <a name="input_security_alert_policy_email_addresses"></a> [security\_alert\_policy\_email\_addresses](#input\_security\_alert\_policy\_email\_addresses) | Email addresses for security alerts | `list(string)` | `[]` | no |
| <a name="input_security_alert_policy_retention_days"></a> [security\_alert\_policy\_retention\_days](#input\_security\_alert\_policy\_retention\_days) | Retention days for security alerts | `number` | `30` | no |
| <a name="input_security_alert_policy_storage_account_access_key"></a> [security\_alert\_policy\_storage\_account\_access\_key](#input\_security\_alert\_policy\_storage\_account\_access\_key) | Storage account access key for security alerts | `string` | `null` | no |
| <a name="input_security_alert_policy_storage_endpoint"></a> [security\_alert\_policy\_storage\_endpoint](#input\_security\_alert\_policy\_storage\_endpoint) | Storage endpoint for security alerts | `string` | `null` | no |
| <a name="input_spark_pools"></a> [spark\_pools](#input\_spark\_pools) | Spark pools configuration | <pre>map(object({<br/>    node_size_family = string<br/>    node_size        = string<br/>    node_count       = optional(number, 3)<br/><br/>    auto_scale = optional(object({<br/>      max_node_count = number<br/>      min_node_count = number<br/>    }))<br/><br/>    auto_pause = optional(object({<br/>      delay_in_minutes = number<br/>    }))<br/><br/>    spark_version = optional(string, "3.2")<br/><br/>    library_requirement = optional(object({<br/>      content  = string<br/>      filename = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_sql_administrator_login"></a> [sql\_administrator\_login](#input\_sql\_administrator\_login) | SQL administrator login name | `string` | `null` | no |
| <a name="input_sql_administrator_login_password"></a> [sql\_administrator\_login\_password](#input\_sql\_administrator\_login\_password) | SQL administrator login password | `string` | `null` | no |
| <a name="input_sql_identity_control_enabled"></a> [sql\_identity\_control\_enabled](#input\_sql\_identity\_control\_enabled) | Enable SQL identity control | `bool` | `true` | no |
| <a name="input_storage_data_lake_gen2_filesystem_id"></a> [storage\_data\_lake\_gen2\_filesystem\_id](#input\_storage\_data\_lake\_gen2\_filesystem\_id) | ID of the Data Lake Storage Gen2 filesystem | `string` | n/a | yes |
| <a name="input_synapse_workspace_name"></a> [synapse\_workspace\_name](#input\_synapse\_workspace\_name) | Name of the Synapse workspace. If null, will be auto-generated. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vulnerability_assessment_emails"></a> [vulnerability\_assessment\_emails](#input\_vulnerability\_assessment\_emails) | Email addresses for vulnerability scans | `list(string)` | `[]` | no |
| <a name="input_vulnerability_assessment_recurring_scans_enabled"></a> [vulnerability\_assessment\_recurring\_scans\_enabled](#input\_vulnerability\_assessment\_recurring\_scans\_enabled) | Enable recurring vulnerability scans | `bool` | `true` | no |
| <a name="input_vulnerability_assessment_storage_account_access_key"></a> [vulnerability\_assessment\_storage\_account\_access\_key](#input\_vulnerability\_assessment\_storage\_account\_access\_key) | Storage account access key for vulnerability assessment | `string` | `null` | no |
| <a name="input_vulnerability_assessment_storage_container_path"></a> [vulnerability\_assessment\_storage\_container\_path](#input\_vulnerability\_assessment\_storage\_container\_path) | Storage container path for vulnerability assessment | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dedicated_sql_pools"></a> [dedicated\_sql\_pools](#output\_dedicated\_sql\_pools) | Dedicated SQL pools |
| <a name="output_firewall_rules"></a> [firewall\_rules](#output\_firewall\_rules) | Firewall rules |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity block |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | Principal ID of the system-assigned managed identity |
| <a name="output_private_endpoint_synapse_dev_id"></a> [private\_endpoint\_synapse\_dev\_id](#output\_private\_endpoint\_synapse\_dev\_id) | Synapse Dev private endpoint ID |
| <a name="output_private_endpoint_synapse_sql_id"></a> [private\_endpoint\_synapse\_sql\_id](#output\_private\_endpoint\_synapse\_sql\_id) | Synapse SQL private endpoint ID |
| <a name="output_private_endpoint_synapse_sql_on_demand_id"></a> [private\_endpoint\_synapse\_sql\_on\_demand\_id](#output\_private\_endpoint\_synapse\_sql\_on\_demand\_id) | Synapse SQL on-demand private endpoint ID |
| <a name="output_spark_pools"></a> [spark\_pools](#output\_spark\_pools) | Spark pools |
| <a name="output_synapse_workspace_connectivity_endpoints"></a> [synapse\_workspace\_connectivity\_endpoints](#output\_synapse\_workspace\_connectivity\_endpoints) | Synapse workspace connectivity endpoints |
| <a name="output_synapse_workspace_id"></a> [synapse\_workspace\_id](#output\_synapse\_workspace\_id) | Synapse workspace ID |
| <a name="output_synapse_workspace_managed_resource_group_name"></a> [synapse\_workspace\_managed\_resource\_group\_name](#output\_synapse\_workspace\_managed\_resource\_group\_name) | Managed resource group name |
| <a name="output_synapse_workspace_name"></a> [synapse\_workspace\_name](#output\_synapse\_workspace\_name) | Synapse workspace name |
<!-- END_TF_DOCS -->

---

## Part of the AIRCLOUD Azure module catalog

Browse all modules with usage snippets in the [module catalog](https://aircloud-pl.github.io/) or on [github.com/AIRCLOUD-PL](https://github.com/AIRCLOUD-PL). Built and maintained by [AIRCLOUD](https://aircloud.com.pl): DevOps, cloud and AI engineering. Need a hand with Azure landing zones or platform engineering? See [aircloud.com.pl/consulting](https://aircloud.com.pl/consulting).
