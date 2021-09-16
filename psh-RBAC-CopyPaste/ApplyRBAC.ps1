# Load settings
$Settings = Get-Content -Path "$PSScriptRoot\settings.json" | ConvertFrom-Json
. "$PSScriptRoot\Utils.ps1"

# Login
Clear-AzureRmContext -Force
$ctx = Connect-AzureRmAccount -Force `
    -Tenant $Settings.DestTenantID `
    -Subscription $Settings.SubscriptionId `
    -ErrorAction Stop
LoginToAAD

# Load lists from source tenant
$SourceRoles = Get-Content -Path "$($PSScriptRoot)\SourceRoleAssignments.json" | ConvertFrom-Json
$SourceUsers = Get-Content -Path "$($PSScriptRoot)\SourceUsers.json" | ConvertFrom-Json
$SourceSPs = Get-Content -Path "$($PSScriptRoot)\SourceSPs.json" | ConvertFrom-Json

# Load destination users
$DestUsers = Get-AzureADUser -All $true | Select ObjectId, ImmutableId, MailNickName, ObjectType, DisplayName, Mail, UserPrincipalName, UserType

# Load destination SPs
$DestSPs = Get-AzureADServicePrincipal -All $true | Select ObjectId, ObjectType, DisplayName, AppDisplayName, AppId

$DestRoles = @()

# Crosswalk users
foreach($sourceUser in $SourceUsers) {
    foreach($destUser in $DestUsers) {
        # Look for match
        $isMatch = ( ($sourceUser.ImmutableId -eq $destUser.ImmutableId) -or ($sourceUser.Mail -eq $destUser.Mail) )
        if ($isMatch) {
            # We have a match - have we updated the DestRoles collection with this dest user?
            $hasRecord = $DestRoles | Where { $_.ObjectId -eq $destUser.ObjectId }
            if (!$hasRecord) {
                $currRoles = $SourceRoles | Where { $_.ObjectId -eq $sourceUser.ObjectId }
                foreach($currRole in $currRoles) {
                    $currRole.ObjectId = $destUser.ObjectId
                    $currRole.DisplayName = $destUser.DisplayName
                    $currRole.SignInName = $destUser.UserPrincipalName
                    $DestRoles += $currRole
                }
            }
        }
    }
}

# Crosswalk SPs
foreach($sourceSP in $SourceSPs) {
    foreach($destSP in $DestSPs) {
        # Look for match
        $isMatch = ($sourceSP.AppDisplayName -eq $destSP.AppDisplayName)
        if ($isMatch) {
            # We have a match - have we updated the DestRoles collection with this dest user?
            $hasRecord = $DestRoles | Where { $_.ObjectId -eq $destSP.ObjectId }
            if (!$hasRecord) {
                $currRoles = $SourceRoles | Where { $_.ObjectId -eq $sourceSP.ObjectId }
                foreach($currRole in $currRoles) {
                    $currRole.ObjectId = $destSP.ObjectId
                    $currRole.DisplayName = $destSP.DisplayName
                    $DestRoles += $currRole
                }
            }
        }
    }
}

# Save the updated role assignments for posterity
$DestRoles | ConvertTo-Json | Out-File "$($PSScriptRoot)\DestinationRoleAssignments.json"

$x=1

# Apply new roles to subscription in new tenant
for ($x = 0; $x -lt $DestRoles.Count; $x++) {
    $role = $DestRoles[$x];
    progress -Current ($x + 1) -Total $DestRoles.Count

    New-AzureRmRoleAssignment `
        -ObjectId $role.ObjectId `
        -RoleDefinitionName $role.RoleDefinitionName `
        -Scope $role.Scope
}
