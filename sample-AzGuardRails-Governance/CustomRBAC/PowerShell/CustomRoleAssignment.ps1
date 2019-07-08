# Retrieve the role definition for the "Virtual Machine Contributor" built-in role
$role = Get-AzRoleDefinition "Virtual Machine Contributor"
# Set the role Id to null as this will be automatically generated when creating a custom role
$role.Id = $null
# Give the role a name and description
$role.Name = "Limited VM Operator"
$role.Description = "Users can monitor, stop, deallocate, and restart virtual machines."
# Remove all actions in this case as we want to start fresh
# If you wanted to grant the default permissions for this role and add new permissions, this step can be skipped.
$role.Actions.Clear()

$role.Actions.Add("Microsoft.Authorization/*/read")
$role.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/read")
$role.Actions.Add("Microsoft.Compute/*/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/powerOff/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/deallocate/action")
$role.Actions.Add("Microsoft.Network/networkInterfaces/read")
$role.Actions.Add("Microsoft.Compute/disks/read")
$role.Actions.Add("Microsoft.Insights/alertRules/read")
$role.Actions.Add("Microsoft.Insights/diagnosticSettings/read")

# Clear the scopes that this applies to
$role.AssignableScopes.Clear()
# Apply it to a specific resource group, note you would need to replace  with the actual subscription id
$role.AssignableScopes.Add("/subscriptions/subscriptions/xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx/resourceGroups/MyResourceGroup")

New-AzRoleDefinition -Role $role
