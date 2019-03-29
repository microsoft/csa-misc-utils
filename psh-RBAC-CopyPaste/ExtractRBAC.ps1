# Load settings
$Settings = Get-Content -Path "$PSScriptRoot\settings.json" | ConvertFrom-Json
. "$PSScriptRoot\Utils.ps1"

# Login
Clear-AzureRmContext -Force
$ctx = Connect-AzureRmAccount -Force `
    -Tenant $Settings.SourceTenantId `
    -Subscription $Settings.SubscriptionId `
    -ErrorAction Stop
LoginToAAD

# Find currently assigned roles in the entire subscription
$RoleAssignments = Get-AzureRmRoleAssignment

# Get all user principals from the tenant
$SourceUsers = Get-AzureADUser -All $true | Select ObjectId, ImmutableId, MailNickName, ObjectType, DisplayName, Mail, UserPrincipalName, UserType
# Get all service principals from the tenant
$SourceSPs = Get-AzureADServicePrincipal -All $true | Select ObjectId, ObjectType, DisplayName, AppDisplayName, AppId

# Clean up the lists
$AssignedSPs = @()
$AssignedUsers = @()

# Filter to find only the SPs that have RBAC assignments
foreach($sp in $SourceSPs) {
    foreach($assigned in $RoleAssignments) {
        if ($sp.ObjectId -eq $assigned.ObjectId) {
            $hasRecord = $AssignedSps | Where { $_.ObjectId -eq $sp.ObjectId }
            if (!$hasRecord) {
                $AssignedSPs += $sp
            }
        }
    }
}

# IMPORTANT - verify that all DisplayNames are UNIQUE - it's all we have to key on
$DupeTest = HasDuplicates -ArrayToTest $AssignedSPs
if ($DupeTest.hasDupes) {
    Write-Warning $DupeTest.dupItems | format-list
    throw "Ensure that all service principles/applications to be migrated have unique display names"
}

# Filter to find only users that have RBAC assignments
foreach($user in $SourceUsers) {
    foreach($assigned in $RoleAssignments) {
        if ($user.ObjectId -eq $assigned.ObjectId) {
            $hasRecord = $AssignedUsers | Where { $_.ObjectId -eq $user.ObjectId }
            if (!$hasRecord) {
                $AssignedUsers += $user
            }
        }
    }
}

# Write the lists to the file system for later import
$AssignedSPs | ConvertTo-Json | Out-File "$($PSScriptRoot)\SourceSPs.json"
$AssignedUsers | ConvertTo-Json | Out-File "$($PSScriptRoot)\SourceUsers.json"
$RoleAssignments | ConvertTo-Json | Out-File "$($PSScriptRoot)\SourceRoleAssignments.json"
