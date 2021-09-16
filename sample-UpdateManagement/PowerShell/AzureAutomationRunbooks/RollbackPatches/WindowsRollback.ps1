<#
Created 
2019.01.25
Shannon Kuehn

Last Updated
2019.07.08

© 2019 Microsoft Corporation. 
All rights reserved. Sample scripts/code provided herein are not supported under any Microsoft standard support program 
or service. The sample scripts/code are provided AS IS without warranty of any kind. Microsoft disclaims all implied 
warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event 
shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for 
any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of 
business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or 
documentation, even if Microsoft has been advised of the possibility of such damages.
#>

#Required parameters to run on a schedule or on-demand.
param(
    [Parameter(Mandatory=$true)]
    [string]$query,
    [Parameter(Mandatory = $true)]
    [string]$workspaceId,
    [Parameter(Mandatory = $true)]
    [string]$KB
)

#Specify the Azure Automation connection. 
$RunAsConnection = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzAccount -CertificateThumbprint $RunAsConnection.CertificateThumbprint `
-ApplicationId $RunAsConnection.ApplicationID -Tenant $RunAsConnection.TenantID -ServicePrincipal
Set-AzContext -SubscriptionId $RunAsConnection.SubscriptionID

#Required Parameters to test with AzureAutomationAuthoringToolkit. Comment out with # if running inside Azure on a schedule.
$workspaceId = "Log Analytics workspace ID goes here"
$KB = 'List KB to uninstall with just numbers, no KB in front'
$query = 'ConfigurationData | where ConfigDataType == "Software" | where SoftwareName == "Security Update for Windows Server 2012 R2 (KB3177186)" | project Computer | distinct Computer'

#Azure Automation Runbook script.
$queryResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $workspaceId -Query $query
$computers = $queryResults.Results | Select-Object -ExpandProperty Computer
foreach ($computer in $computers)
    {
        Invoke-Command -ComputerName $computer -ScriptBlock {C:\Windows\System32\wusa.exe /kb:$KB /uninstall /quiet /norestart} -Verbose
    }
