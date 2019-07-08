<#PSScriptInfo 
https://www.powershellgallery.com/packages/Export-RunAsCertificateToHybridWorker/1.0/Content/Export-RunAsCertificateToHybridWorker.ps1

.VERSION 1.0 
.GUID 3a796b9a-623d-499d-86c8-c249f10a6986 
.AUTHOR Azure Automation Team 
.COMPANYNAME Microsoft 
.COPYRIGHT 
.TAGS Azure Automation 
.LICENSEURI 
.PROJECTURI 
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES 
#>

<# 
.SYNOPSIS 
  Exports the Run As certificate from an Azure Automation account to a hybrid worker in that account. 
   
.DESCRIPTION 
  This runbook exports the Run As certificate from an Azure Automation account to a hybrid worker in that account. 
  Run this runbook in the hybrid worker where you want the certificate installed. 
  This allows the use of the AzureRunAsConnection to authenticate to Azure and manage Azure resources from runbooks running in the hybrid worker. 
 
.EXAMPLE 
  .\Export-RunAsCertificateToHybridWorker 
 
.NOTES 
   AUTHOR: Azure Automation Team 
   LASTEDIT: 2016.10.13 
#>

[OutputType([string])] 

# Set the password used for this certificate
$Password = "YourStrongPasswordForTheCert"

# Stop on errors
$ErrorActionPreference = 'stop'

# Get the management certificate that will be used to make calls into Azure Service Management resources
$RunAsCert = Get-AutomationCertificate -Name "AzureRunAsCertificate"
       
# location to store temporary certificate in the Automation service host
$CertPath = Join-Path $env:temp  "AzureRunAsCertificate.pfx"
   
# Save the certificate
$Cert = $RunAsCert.Export("pfx",$Password)
Set-Content -Value $Cert -Path $CertPath -Force -Encoding Byte | Write-Verbose 

Write-Output ("Importing certificate into local machine root store from " + $CertPath)
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
Import-PfxCertificate -FilePath $CertPath -CertStoreLocation Cert:\LocalMachine\My -Password $SecurePassword -Exportable | Write-Verbose

# Test that authentication to Azure ARM is working
$RunAsConnection = Get-AutomationConnection -Name "AzureRunAsConnection" 
    
Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $RunAsConnection.TenantId `
    -ApplicationId $RunAsConnection.ApplicationId `
    -CertificateThumbprint $RunAsConnection.CertificateThumbprint | Write-Verbose

Select-AzureRmSubscription -SubscriptionId $RunAsConnection.SubscriptionID | Write-Verbose

# List automation accounts to confirm ARM calls are working
Get-AzureRmAutomationAccount | Select AutomationAccountName
