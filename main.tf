/**
 * # Azure Synapse Analytics Module
 *
 * Enterprise-grade Azure Synapse Analytics module with comprehensive security, compliance, and performance features.
 *
 * ## Features
 * - Dedicated SQL pools and serverless SQL pools
 * - Spark pools for big data analytics
 * - Data Lake integration
 * - Advanced security (encryption, private endpoints, threat protection)
 * - Managed Virtual Networks
 * - Data exfiltration protection
 * - Azure Policy integration
 * - Performance monitoring and optimization
 */

locals {
  # Auto-generate Synapse Workspace name if not provided
  synapse_workspace_name = var.synapse_workspace_name != null ? var.synapse_workspace_name : "${var.naming_prefix}${var.environment}${replace(var.location, "-", "")}synapse"

  # Default tags
  default_tags = {
    ManagedBy   = "Terraform"
    Module      = "azure-synapse"
    Environment = var.environment
  }

  tags = merge(local.default_tags, var.tags)
}

# Synapse Workspace
resource "azurerm_synapse_workspace" "main" {
  name                                 = local.synapse_workspace_name
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = var.storage_data_lake_gen2_filesystem_id
  sql_administrator_login              = var.sql_administrator_login
  sql_administrator_login_password     = var.sql_administrator_login_password

  # Managed Virtual Network
  managed_virtual_network_enabled = var.managed_virtual_network_enabled
  managed_resource_group_name     = var.managed_resource_group_name != null ? var.managed_resource_group_name : "${var.resource_group_name}-synapse-managed"

  # Data exfiltration protection
  data_exfiltration_protection_enabled = var.data_exfiltration_protection_enabled

  # Azure AD integration
  azuread_authentication_only = var.azuread_authentication_only

  # Customer-managed key
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []
    content {
      key_versionless_id = customer_managed_key.value.key_versionless_id
    }
  }

  # Git integration
  dynamic "github_repo" {
    for_each = var.github_repo != null ? [var.github_repo] : []
    content {
      account_name    = github_repo.value.account_name
      branch_name     = github_repo.value.branch_name
      repository_name = github_repo.value.repository_name
      root_folder     = github_repo.value.root_folder
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  # SQL identity control
  sql_identity_control_enabled = var.sql_identity_control_enabled

  # Public network access
  public_network_access_enabled = var.public_network_access_enabled

  # Purview integration
  purview_id = var.purview_id

  # Linking
  linking_allowed_for_aad_tenant_ids = var.linking_allowed_for_aad_tenant_ids

  tags = local.tags
}

# Security Alert Policy
resource "azurerm_synapse_workspace_security_alert_policy" "main" {
  count = var.enable_security_alert_policy ? 1 : 0

  synapse_workspace_id       = azurerm_synapse_workspace.main.id
  policy_state               = "Enabled"
  disabled_alerts            = var.security_alert_policy_disabled_alerts
  email_addresses            = var.security_alert_policy_email_addresses
  retention_days             = var.security_alert_policy_retention_days
  storage_account_access_key = var.security_alert_policy_storage_account_access_key
  storage_endpoint           = var.security_alert_policy_storage_endpoint
}

# Vulnerability Assessment
resource "azurerm_synapse_workspace_vulnerability_assessment" "main" {
  count = var.enable_vulnerability_assessment ? 1 : 0

  workspace_security_alert_policy_id = azurerm_synapse_workspace_security_alert_policy.main[0].id
  storage_container_path             = var.vulnerability_assessment_storage_container_path
  storage_account_access_key         = var.vulnerability_assessment_storage_account_access_key

  recurring_scans {
    enabled = var.vulnerability_assessment_recurring_scans_enabled
    emails  = var.vulnerability_assessment_emails
  }
}

# SQL Audit Policy
resource "azurerm_synapse_workspace_extended_auditing_policy" "main" {
  count = var.enable_extended_auditing_policy ? 1 : 0

  synapse_workspace_id       = azurerm_synapse_workspace.main.id
  storage_endpoint           = var.auditing_policy_storage_endpoint
  storage_account_access_key = var.auditing_policy_storage_account_access_key
  retention_in_days          = var.auditing_policy_retention_in_days
}

# Dedicated SQL Pools
resource "azurerm_synapse_sql_pool" "dedicated_pools" {
  for_each = var.dedicated_sql_pools

  name                 = each.key
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  sku_name             = each.value.sku_name
  storage_account_type = try(each.value.storage_account_type, "GRS")
  create_mode          = try(each.value.create_mode, "Default")

  # Recovery configuration
  recovery_database_id = try(each.value.recovery_database_id, null)

  # Restore configuration
  dynamic "restore" {
    for_each = try(each.value.restore, null) != null ? [each.value.restore] : []
    content {
      source_database_id = restore.value.source_database_id
      point_in_time      = restore.value.point_in_time
    }
  }

  # Geo-backup policy
  geo_backup_policy_enabled = try(each.value.geo_backup_policy_enabled, true)

  # Data warehouse settings
  data_encrypted = try(each.value.data_encrypted, true)

  collation = try(each.value.collation, "SQL_Latin1_General_CP1_CI_AS")
}

# Spark Pools
resource "azurerm_synapse_spark_pool" "pools" {
  for_each = var.spark_pools

  name                 = each.key
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  node_size_family     = each.value.node_size_family
  node_size            = each.value.node_size
  node_count           = try(each.value.node_count, 3)

  # Auto-scaling
  dynamic "auto_scale" {
    for_each = try(each.value.auto_scale, null) != null ? [each.value.auto_scale] : []
    content {
      max_node_count = auto_scale.value.max_node_count
      min_node_count = auto_scale.value.min_node_count
    }
  }

  # Auto-pause
  dynamic "auto_pause" {
    for_each = try(each.value.auto_pause, null) != null ? [each.value.auto_pause] : []
    content {
      delay_in_minutes = auto_pause.value.delay_in_minutes
    }
  }

  # Spark version
  spark_version = try(each.value.spark_version, "3.2")

  # Library requirement
  dynamic "library_requirement" {
    for_each = try(each.value.library_requirement, null) != null ? [each.value.library_requirement] : []
    content {
      content  = library_requirement.value.content
      filename = library_requirement.value.filename
    }
  }

  tags = local.tags
}

# Firewall Rules
resource "azurerm_synapse_firewall_rule" "firewall_rules" {
  for_each = var.firewall_rules

  name                 = each.key
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  start_ip_address     = each.value.start_ip_address
  end_ip_address       = each.value.end_ip_address
}

# Private Endpoints
resource "azurerm_private_endpoint" "synapse_sql" {
  count = var.private_endpoints.synapse_sql != null ? 1 : 0

  name                = "${azurerm_synapse_workspace.main.name}-sql-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints.synapse_sql.subnet_id

  private_service_connection {
    name                           = "${azurerm_synapse_workspace.main.name}-sql-psc"
    private_connection_resource_id = azurerm_synapse_workspace.main.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_endpoints.synapse_sql.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = "synapse-sql-dns-zone-group"
      private_dns_zone_ids = var.private_endpoints.synapse_sql.private_dns_zone_ids
    }
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "synapse_sql_on_demand" {
  count = var.private_endpoints.synapse_sql_on_demand != null ? 1 : 0

  name                = "${azurerm_synapse_workspace.main.name}-sqlod-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints.synapse_sql_on_demand.subnet_id

  private_service_connection {
    name                           = "${azurerm_synapse_workspace.main.name}-sqlod-psc"
    private_connection_resource_id = azurerm_synapse_workspace.main.id
    subresource_names              = ["SqlOnDemand"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_endpoints.synapse_sql_on_demand.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = "synapse-sqlod-dns-zone-group"
      private_dns_zone_ids = var.private_endpoints.synapse_sql_on_demand.private_dns_zone_ids
    }
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "synapse_dev" {
  count = var.private_endpoints.synapse_dev != null ? 1 : 0

  name                = "${azurerm_synapse_workspace.main.name}-dev-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints.synapse_dev.subnet_id

  private_service_connection {
    name                           = "${azurerm_synapse_workspace.main.name}-dev-psc"
    private_connection_resource_id = azurerm_synapse_workspace.main.id
    subresource_names              = ["Dev"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_endpoints.synapse_dev.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = "synapse-dev-dns-zone-group"
      private_dns_zone_ids = var.private_endpoints.synapse_dev.private_dns_zone_ids
    }
  }

  tags = local.tags
}