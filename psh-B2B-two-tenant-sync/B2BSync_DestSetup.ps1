<#
Configure DESTINATION site - one-time, add appropriate roles to the DEST site service principal
MUST BE RUN AND LOGGED IN BY DESTINATION TENANT GLOBAL ADMIN
See README.txt for details
#IMPORTANT: edit "B2BSync-MyVars.ps1 and fill in your variables - see README
#>

# Dot-sourcing variables - update "B2BSync-Myvars.ps1 and use that file name
. "$PSScriptRoot\B2BSync-MyVars.ps1"
. "$PSScriptRoot\B2BSync_CustomAttributes.ps1"

# Global Admin login to destination tenant
Connect-AzureAD -TenantId $DestTenantId

$RolesToEnable = @("Guest Inviter")
$sp = Get-AzureADServicePrincipal -Filter "AppId eq `'$appID`'"

foreach($rolename in $RolesToEnable){
    Write-Host "Enabling role $Rolename for Service Principal $($sp.DisplayName)"
    $roleId = (Get-AzureADDirectoryRole | where { $_.DisplayName -eq $roleName }).ObjectId
    Add-AzureADDirectoryRoleMember -ObjectId $roleId -RefObjectId $sp.ObjectId
}

$aadapp = Get-AzureADApplication -Filter "DisplayName eq '$($sp.AppDisplayName)'"  -ErrorAction Stop

#add custom attribute to app and tenant
New-AppExtAttrFromSettings -AppObjId $aadapp.ObjectId