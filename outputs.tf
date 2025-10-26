output "synapse_workspace_id" {
  description = "Synapse workspace ID"
  value       = azurerm_synapse_workspace.main.id
}

output "synapse_workspace_name" {
  description = "Synapse workspace name"
  value       = azurerm_synapse_workspace.main.name
}

output "synapse_workspace_connectivity_endpoints" {
  description = "Synapse workspace connectivity endpoints"
  value       = azurerm_synapse_workspace.main.connectivity_endpoints
}

output "synapse_workspace_managed_resource_group_name" {
  description = "Managed resource group name"
  value       = azurerm_synapse_workspace.main.managed_resource_group_name
}

output "dedicated_sql_pools" {
  description = "Dedicated SQL pools"
  value       = azurerm_synapse_sql_pool.dedicated_pools
}

output "spark_pools" {
  description = "Spark pools"
  value       = azurerm_synapse_spark_pool.pools
}

output "firewall_rules" {
  description = "Firewall rules"
  value       = azurerm_synapse_firewall_rule.firewall_rules
}

output "identity" {
  description = "Managed identity block"
  value       = var.identity_type != null ? azurerm_synapse_workspace.main.identity : null
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity"
  value       = var.identity_type != null ? azurerm_synapse_workspace.main.identity[0].principal_id : null
}

output "private_endpoint_synapse_sql_id" {
  description = "Synapse SQL private endpoint ID"
  value       = var.private_endpoints.synapse_sql != null ? azurerm_private_endpoint.synapse_sql[0].id : null
}

output "private_endpoint_synapse_sql_on_demand_id" {
  description = "Synapse SQL on-demand private endpoint ID"
  value       = var.private_endpoints.synapse_sql_on_demand != null ? azurerm_private_endpoint.synapse_sql_on_demand[0].id : null
}

output "private_endpoint_synapse_dev_id" {
  description = "Synapse Dev private endpoint ID"
  value       = var.private_endpoints.synapse_dev != null ? azurerm_private_endpoint.synapse_dev[0].id : null
}