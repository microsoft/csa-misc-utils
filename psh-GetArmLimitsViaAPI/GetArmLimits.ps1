<#
.SYNOPSIS

There are limits to the number of read/write operations that can be performed against the Azure Resource manager proviers in Azure. 
When this limit is reached there will be an HTTP 429 error returned.  The documentation below outlines the specific REST call but
does not provide a complete example

https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-request-limits

.DESCRIPTION

This script creates the proper bearer token to invoke the REST API on the number of remaining Read Operations allowed against a specific 
subscription.  The function Get-AzureCachedAccessToken provides the logic to pull the access token required to pass into the REST API

#>


function Get-AzureRmCachedAccessToken()
{
  $ErrorActionPreference = 'Stop'
  
  if(-not (Get-Module AzureRm.Profile)) {
    Import-Module AzureRm.Profile
  }
  $azureRmProfileModuleVersion = (Get-Module AzureRm.Profile).Version
  # refactoring performed in AzureRm.Profile v3.0 or later
  if($azureRmProfileModuleVersion.Major -ge 3) {
    $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    if(-not $azureRmProfile.Accounts.Count) {
      Write-Error "Ensure you have logged in before calling this function."    
    }
  } else {
    # AzureRm.Profile < v3.0
    $azureRmProfile = [Microsoft.WindowsAzure.Commands.Common.AzureRmProfileProvider]::Instance.Profile
    if(-not $azureRmProfile.Context.Account.Count) {
      Write-Error "Ensure you have logged in before calling this function."    
    }
  }
  
  $currentAzureContext = Get-AzureRmContext
  $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
  Write-Debug ("Getting access token for tenant" + $currentAzureContext.Subscription.TenantId)
  $token = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId)
  $token.AccessToken

 }


Write-Host "Log in to your Azure subscription..." -ForegroundColor Green
#Login-AzureRmAccount
#Get-AzureRmSubscription -SubscriptionName $SubscriptionName | Select-AzureRmSubscription

$token = Get-AzureRmCachedAccessToken
$currentAzureContext = Get-AzureRmContext
Write-Host ("Getting access ARM Throttle Limits for Subscription: " + $currentAzureContext.Subscription)


$requestHeader = @{
  "Authorization" = "Bearer " + $token
  "Content-Type" = "application/json"
}

$Uri = "https://management.azure.com/subscriptions/" + $currentAzureContext.Subscription + "/resourcegroups?api-version=2016-09-01"
$r = Invoke-WebRequest -Uri $Uri -Method GET -Headers $requestHeader
write-host("Remaining Read Operations: " + $r.Headers["x-ms-ratelimit-remaining-subscription-reads"])