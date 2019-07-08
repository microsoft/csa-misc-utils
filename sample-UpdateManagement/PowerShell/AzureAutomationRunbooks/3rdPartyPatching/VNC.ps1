<#
Created 
2019.02.07
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
    [Parameter(Mandatory = $true)]
    [string]$sourcePath,
    [Parameter(Mandatory = $true)]
    [string]$workspaceId,
    [Parameter(Mandatory = $true)]
    [string]$query
)

#Specify the Azure Automation connection.
$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzAccount -ServicePrincipal -Tenant $Conn.TenantID `
-ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
Set-AzContext -SubscriptionId $Conn.SubscriptionID

#Required Parameters to test with AzureAutomationAuthoringToolkit. Comment out with # if running inside Azure on a schedule.
$sourcePath = '\\server\share\AppPatching\RealVNC\'
$workspaceId = "Log Analytics workspace ID goes here"
$query = 'ConfigurationData | where ConfigDataType == "Software" | where SoftwareName == "VNC Server 6.0.0" | distinct Computer'
$queryResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $workspaceId -Query $query
$computername = $queryResults.Results | Select-Object -ExpandProperty Computer

#Run the installation script.
ForEach($computer in $computername){
    Copy-Item -Path $sourcePath -Destination \\$computer\c$\ -Recurse -Force
    $session = New-PSSession -ComputerName $computer
        Invoke-Command -Session $session -ScriptBlock {
            $process = New-Object System.Diagnostics.Process  
            $process.StartInfo.FileName = "msiexec"
            $process.StartInfo.Arguments = " /i `"C:\RealVNC\VNC-Server-6.4.0-Windows-en-64bit.msi`" /qn"
            $process.StartInfo.Verb = "RunAs"
            $process.Start()
    }
    Enter-PSSession -Session $session
    Exit-PSSession
}
