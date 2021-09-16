$ADGroup = "Developers"
$ADGroupSearch = Get-AzADGroup -SearchString $ADGroup

#Scope should be subscription ID in form of "subscriptions/xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx" : 
#Can only add one subscription in this form

$scope = ""

$role = Get-AzRoleDefinition "Reader" 
$role.id = $null
$role.name = "Developer"
$role.Description = "Cloud Developer Role"
$role.Actions.Clear()
$role.NotActions.Clear()
$role.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/write")
$role.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/read")
$role.Actions.Add("Microsoft.Storage/storageaccounts/write")
$role.Actions.Add("Microsoft.Storage/storageAccounts/read")
$role.Actions.Add("Microsoft.Network/virtualNetworks/read")
$role.Actions.Add("Microsoft.Network/virtualNetworks/subnets/read")
$role.Actions.Add("Microsoft.Network/virtualNetworks/subnets/join/action")
$role.Actions.Add("Microsoft.Network/networkInterfaces/*")
$role.Actions.Add("Microsoft.resources/deployments/*")
$role.Actions.Add("Microsoft.Compute/*")
$role.Actions.Add("Microsoft.Sql/*")
$role.Actions.Add("Microsoft.Web/sites/*")
$role.Actions.Add("Microsoft.Insights/*")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add($scope)

New-AzRoleDefinition -Role $role 

New-AzRoleAssignment -ObjectId $ADGroupSearch.Id.Guid -RoleDefinitionName $role.name -Scope $scope
