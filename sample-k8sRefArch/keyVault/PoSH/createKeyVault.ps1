# Script Notes
# $subscriptionName is the name of the Azure subscription to install the Key Vault into
# $resourceGroupName is the resource group that will contain the Key Vault to create to contain Key Vault secrets, passwords, and certificates
# $keyVaultName is the name of the Key Vault you are deploying
# $location is the region your Key Vault is deploying to
# $keyVaultAdminUser - Azure AD users or groups that have access to Key Vault

param(
        [Parameter(Mandatory=$true)]
        [string] $subscriptionName,
        [Parameter(Mandatory=$true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory=$true)]
        [string] $keyVaultName,
        [Parameter(Mandatory=$true)]
        [string] $location,
        [Parameter(Mandatory=$true)]
        [string] $keyVaultAdminUser
)

# Login to Azure
Login-AzAccount

# Select the appropriate subscription
Select-AzSubscription -SubscriptionName $subscriptionName

# Make the Key Vault provider is available (commented out - if not registered, uncomment the line below and run in PowerShell):
# Register-AzureRmResourceProvider -ProviderNamespace Microsoft.KeyVault

# Create the Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create the Key Vault (enabling it for Disk Encryption, Deployment and Template Deployment)
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location $location `
    -EnabledForDiskEncryption -EnabledForDeployment -EnabledForTemplateDeployment

# Add the Administrator policies to the Key Vault
$ObjectId = (Get-AzADUser -UserPrincipalName $keyVaultAdminUser).Id

# Set access policy for Key Vault
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -ObjectId $ObjectId `
-PermissionsToKeys decrypt,encrypt,unwrapKey,wrapKey,verify,sign,get,list,update,create,import,delete,backup,restore,recover,purge `
–PermissionsToSecrets get,list,set,delete,backup,restore,recover,purge `
–PermissionsToCertificates get,list,delete,create,import,update,managecontacts,getissuers,listissuers,setissuers,deleteissuers,manageissuers,recover,purge,backup,restore `
-PermissionsToStorage get,list,delete,set,update,regeneratekey,getsas,listsas,deletesas,setsas,recover,backup,restore,purge 
