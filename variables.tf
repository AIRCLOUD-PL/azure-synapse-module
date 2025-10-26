variable "synapse_workspace_name" {
  description = "Name of the Synapse workspace. If null, will be auto-generated."
  type        = string
  default     = null
}

variable "naming_prefix" {
  description = "Prefix for Synapse naming"
  type        = string
  default     = "synapse"
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, test)"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "storage_data_lake_gen2_filesystem_id" {
  description = "ID of the Data Lake Storage Gen2 filesystem"
  type        = string
}

variable "sql_administrator_login" {
  description = "SQL administrator login name"
  type        = string
  default     = null
}

variable "sql_administrator_login_password" {
  description = "SQL administrator login password"
  type        = string
  default     = null
  sensitive   = true
}

variable "managed_virtual_network_enabled" {
  description = "Enable managed virtual network"
  type        = bool
  default     = true
}

variable "managed_resource_group_name" {
  description = "Name of the managed resource group"
  type        = string
  default     = null
}

variable "data_exfiltration_protection_enabled" {
  description = "Enable data exfiltration protection"
  type        = bool
  default     = true
}

variable "azuread_authentication_only" {
  description = "Enable Azure AD authentication only"
  type        = bool
  default     = false
}

variable "customer_managed_key" {
  description = "Customer managed key configuration"
  type = object({
    key_versionless_id = string
  })
  default = null
}

variable "github_repo" {
  description = "GitHub repository configuration"
  type = object({
    account_name    = string
    branch_name     = string
    repository_name = string
    root_folder     = optional(string, "/")
  })
  default = null
}

variable "identity_type" {
  description = "Type of Managed Identity"
  type        = string
  default     = "SystemAssigned"
  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  description = "List of User Assigned Identity IDs"
  type        = list(string)
  default     = []
}

variable "sql_identity_control_enabled" {
  description = "Enable SQL identity control"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = false
}

variable "purview_id" {
  description = "Purview resource ID for integration"
  type        = string
  default     = null
}

variable "linking_allowed_for_aad_tenant_ids" {
  description = "List of AAD tenant IDs allowed for linking"
  type        = list(string)
  default     = []
}

variable "enable_security_alert_policy" {
  description = "Enable security alert policy"
  type        = bool
  default     = true
}

variable "security_alert_policy_disabled_alerts" {
  description = "Disabled alerts for security policy"
  type        = list(string)
  default     = []
}

variable "security_alert_policy_email_account_admins" {
  description = "Email account admins for security alerts"
  type        = bool
  default     = true
}

variable "security_alert_policy_email_addresses" {
  description = "Email addresses for security alerts"
  type        = list(string)
  default     = []
}

variable "security_alert_policy_retention_days" {
  description = "Retention days for security alerts"
  type        = number
  default     = 30
}

variable "security_alert_policy_storage_account_access_key" {
  description = "Storage account access key for security alerts"
  type        = string
  default     = null
  sensitive   = true
}

variable "security_alert_policy_storage_endpoint" {
  description = "Storage endpoint for security alerts"
  type        = string
  default     = null
}

variable "enable_vulnerability_assessment" {
  description = "Enable vulnerability assessment"
  type        = bool
  default     = true
}

variable "vulnerability_assessment_storage_container_path" {
  description = "Storage container path for vulnerability assessment"
  type        = string
  default     = null
}

variable "vulnerability_assessment_storage_account_access_key" {
  description = "Storage account access key for vulnerability assessment"
  type        = string
  default     = null
  sensitive   = true
}

variable "vulnerability_assessment_recurring_scans_enabled" {
  description = "Enable recurring vulnerability scans"
  type        = bool
  default     = true
}

variable "vulnerability_assessment_emails" {
  description = "Email addresses for vulnerability scans"
  type        = list(string)
  default     = []
}

variable "enable_extended_auditing_policy" {
  description = "Enable extended auditing policy"
  type        = bool
  default     = true
}

variable "auditing_policy_storage_endpoint" {
  description = "Storage endpoint for auditing policy"
  type        = string
  default     = null
}

variable "auditing_policy_storage_account_access_key" {
  description = "Storage account access key for auditing"
  type        = string
  default     = null
  sensitive   = true
}

variable "auditing_policy_retention_in_days" {
  description = "Retention days for auditing logs"
  type        = number
  default     = 30
}

variable "dedicated_sql_pools" {
  description = "Dedicated SQL pools configuration"
  type = map(object({
    sku_name             = string
    storage_account_type = optional(string, "GRS")
    create_mode          = optional(string, "Default")
    recovery_database_id = optional(string)
    restore = optional(object({
      source_database_id = string
      point_in_time      = string
    }))
    geo_backup_policy_enabled = optional(bool, true)
    data_encrypted            = optional(bool, true)
    collation                 = optional(string, "SQL_Latin1_General_CP1_CI_AS")
  }))
  default = {}
}

variable "spark_pools" {
  description = "Spark pools configuration"
  type = map(object({
    node_size_family = string
    node_size        = string
    node_count       = optional(number, 3)

    auto_scale = optional(object({
      max_node_count = number
      min_node_count = number
    }))

    auto_pause = optional(object({
      delay_in_minutes = number
    }))

    spark_version = optional(string, "3.2")

    library_requirement = optional(object({
      content  = string
      filename = string
    }))
  }))
  default = {}
}

variable "firewall_rules" {
  description = "Firewall rules configuration"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "private_endpoints" {
  description = "Private endpoint configurations"
  type = object({
    synapse_sql = optional(object({
      subnet_id            = string
      private_dns_zone_ids = optional(list(string))
    }))
    synapse_sql_on_demand = optional(object({
      subnet_id            = string
      private_dns_zone_ids = optional(list(string))
    }))
    synapse_dev = optional(object({
      subnet_id            = string
      private_dns_zone_ids = optional(list(string))
    }))
  })
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}