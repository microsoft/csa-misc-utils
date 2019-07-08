# Adds an individual secret to Key Vault

param(
        [Parameter(Mandatory=$true)]
        [string] $keyVaultName
        [Parameter(Mandatory=$true)]
        [string] $secretName
)

Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -SecretValue (Get-Credential).Password
