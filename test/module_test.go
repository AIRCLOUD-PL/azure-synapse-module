package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSynapseModuleBasic(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",

		Vars: map[string]interface{}{
			"resource_group_name":                   "rg-test-synapse-basic",
			"location":                             "westeurope",
			"environment":                          "test",
			"storage_data_lake_gen2_filesystem_id": "https://storage.dfs.core.windows.net/filesystem",
			"sql_administrator_login":              "sqladmin",
			"sql_administrator_login_password":     "P@ssw0rd123!",
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_synapse_workspace.main")
}

func TestSynapseModuleWithSecurity(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"resource_group_name":                   "rg-test-synapse-security",
			"location":                             "westeurope",
			"environment":                          "test",
			"storage_data_lake_gen2_filesystem_id": "https://storage.dfs.core.windows.net/filesystem",
			"sql_administrator_login":              "sqladmin",
			"sql_administrator_login_password":     "P@ssw0rd123!",
			"managed_virtual_network_enabled":      true,
			"data_exfiltration_protection_enabled": true,
			"public_network_access_enabled":        false,
			"identity_type":                        "SystemAssigned",
			"enable_security_alert_policy":         true,
			"enable_vulnerability_assessment":      true,
			"enable_extended_auditing_policy":      true,
			"dedicated_sql_pools": map[string]interface{}{
				"datapool": map[string]interface{}{
					"sku_name": "DW100c",
				},
			},
			"spark_pools": map[string]interface{}{
				"sparkpool": map[string]interface{}{
					"node_size_family": "MemoryOptimized",
					"node_size":        "Small",
					"node_count":       3,
				},
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_synapse_workspace.main")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_synapse_workspace_security_alert_policy.main")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_synapse_sql_pool.dedicated_pools")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_synapse_spark_pool.pools")
}

func TestSynapseModuleWithPrivateEndpoint(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"resource_group_name":                   "rg-test-synapse-pe",
			"location":                             "westeurope",
			"environment":                          "test",
			"storage_data_lake_gen2_filesystem_id": "https://storage.dfs.core.windows.net/filesystem",
			"sql_administrator_login":              "sqladmin",
			"sql_administrator_login_password":     "P@ssw0rd123!",
			"public_network_access_enabled":        false,
			"private_endpoints": map[string]interface{}{
				"synapse_sql": map[string]interface{}{
					"subnet_id": "/subscriptions/sub/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet",
				},
				"synapse_dev": map[string]interface{}{
					"subnet_id": "/subscriptions/sub/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet",
				},
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_private_endpoint.synapse_sql")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_private_endpoint.synapse_dev")
}

func TestSynapseModuleNamingConvention(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",

		Vars: map[string]interface{}{
			"resource_group_name":                   "rg-test-synapse-naming",
			"location":                             "westeurope",
			"environment":                          "prod",
			"naming_prefix":                        "synapseprod",
			"storage_data_lake_gen2_filesystem_id": "https://storage.dfs.core.windows.net/filesystem",
			"sql_administrator_login":              "sqladmin",
			"sql_administrator_login_password":     "P@ssw0rd123!",
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	resourceChanges := terraform.GetResourceChanges(t, planStruct)

	for _, change := range resourceChanges {
		if change.Type == "azurerm_synapse_workspace" && change.Change.After != null {
			afterMap := change.Change.After.(map[string]interface{})
			if name, ok := afterMap["name"]; ok {
				synapseName := name.(string)
				assert.Contains(t, synapseName, "prod", "Synapse workspace name should contain environment")
			}
		}
	}
}

func TestSynapseModuleWithGitIntegration(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"resource_group_name":                   "rg-test-synapse-git",
			"location":                             "westeurope",
			"environment":                          "test",
			"storage_data_lake_gen2_filesystem_id": "https://storage.dfs.core.windows.net/filesystem",
			"sql_administrator_login":              "sqladmin",
			"sql_administrator_login_password":     "P@ssw0rd123!",
			"github_repo": map[string]interface{}{
				"account_name":    "AIRCLOUD-PL",
				"branch_name":     "main",
				"repository_name": "terraform-synapse",
				"root_folder":     "/",
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_synapse_workspace.main")
}