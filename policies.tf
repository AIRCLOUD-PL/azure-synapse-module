/**
 * Security configurations and policies for Synapse Analytics
 */

# Azure Policy - Require encryption at rest
resource "azurerm_resource_group_policy_assignment" "synapse_encryption" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${azurerm_synapse_workspace.main.name}-encryption"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/3bdb56b7-2e32-4cf3-8036-1b4b3e4a7b2e"
  display_name         = "Synapse workspaces should use customer-managed keys to encrypt data at rest"
  description          = "Ensures Synapse workspaces use customer-managed keys for encryption"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Azure Policy - Require managed virtual network
resource "azurerm_resource_group_policy_assignment" "synapse_managed_vnet" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${azurerm_synapse_workspace.main.name}-managed-vnet"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2d9d1e11-4ab8-4aa6-9e80-123456789abc"
  display_name         = "Synapse workspaces should use managed virtual network"
  description          = "Ensures Synapse workspaces use managed virtual networks"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Azure Policy - Require data exfiltration protection
resource "azurerm_resource_group_policy_assignment" "synapse_data_exfiltration" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${azurerm_synapse_workspace.main.name}-data-exfiltration"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2d9d1e11-4ab8-4aa6-9e80-123456789abd"
  display_name         = "Synapse workspaces should have data exfiltration protection enabled"
  description          = "Ensures data exfiltration protection is enabled for Synapse workspaces"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Azure Policy - Require auditing
resource "azurerm_resource_group_policy_assignment" "synapse_auditing" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${azurerm_synapse_workspace.main.name}-auditing"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/3a9eb14b-26f5-4e22-a3bc-78053b2e7c5e"
  display_name         = "Synapse workspaces should have auditing enabled"
  description          = "Ensures auditing is enabled for Synapse workspaces"

  parameters = jsonencode({
    effect = {
      value = "AuditIfNotExists"
    }
  })
}

# Azure Policy - Require threat detection
resource "azurerm_resource_group_policy_assignment" "synapse_threat_detection" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${azurerm_synapse_workspace.main.name}-threat-detection"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2d9d1e11-4ab8-4aa6-9e80-123456789abe"
  display_name         = "Synapse workspaces should have threat detection enabled"
  description          = "Ensures threat detection is enabled for Synapse workspaces"

  parameters = jsonencode({
    effect = {
      value = "AuditIfNotExists"
    }
  })
}

# Data source for resource group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Variables for policies
variable "enable_policy_assignments" {
  description = "Enable Azure Policy assignments for this Synapse workspace"
  type        = bool
  default     = true
}