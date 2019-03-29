<#
IMPORTANT: this script doesn't attempt to replicate any API permissions, reply urls, or any other attributes of the 
application. It only recreates it in the destination tenant using the same name. If other settings are required,
you'll need to update what's happening in "CreateSP" or manually update the app after it's created by reviewing 
the settings of the source object.
#>

# Load settings
$Settings = Get-Content -Path "$PSScriptRoot\settings.json" | ConvertFrom-Json
. "$PSScriptRoot\Utils.ps1"

# Login
Clear-AzureRmContext -Force
$ctx = Connect-AzureRmAccount `
    -Force `
    -Tenant $Settings.DestTenantID `
    -ErrorAction Stop
LoginToAAD

# Load source SPs
$SourceSPs = Get-Content -Path "$($PSScriptRoot)\SourceSPs.json" | ConvertFrom-Json

$newSPList = @()
foreach($sp in $SourceSPs) {
    $servicePrincipal = CreateSP `
        -DisplayName $sp.AppDisplayName `
        -Tenant $settings.DestTenant

    $newSPList += @{
        "AppId" = $servicePrincipal.App.AppId
        "DisplayName" = $servicePrincipal.App.DisplayName
        "SPObjectId" = $servicePrincipal.SP.ObjectId
        "AppObjectId" = $servicePrincipal.App.ObjectId
        "ServicePrincipalNames" = $servicePrincipal.SP.ServicePrincipalNames
        "ClearPassword" = $servicePrincipal.ClearPW
    }
    $count++
}

$newSPList | format-list
$newSPList | ConvertTo-Json | Out-File "$($PSScriptRoot)\NewServicePrincipals.json"
