<#
Created 
2018.11.26 
Shannon Kuehn

Last Updated
2019.07.08

© 2018 Microsoft Corporation. 
All rights reserved. Sample scripts/code provided herein are not supported under any Microsoft standard support program 
or service. The sample scripts/code are provided AS IS without warranty of any kind. Microsoft disclaims all implied 
warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event 
shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for 
any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of 
business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or 
documentation, even if Microsoft has been advised of the possibility of such damages.
#>

function SetSchedule {
    param(
    [Parameter(Mandatory=$true)]
    [string]$startTime,
    [Parameter(Mandatory=$true)]
    [array]$group,
    [Parameter(Mandatory=$true)]
    [string]$resourceGroup,
    [Parameter(Mandatory=$true)]
    [string]$automationAccount,
    [Parameter(Mandatory=$true)]
    [string]$DaysofMonth,
    [Parameter(Mandatory=$true)]
    [int]$durationHours,
    [Parameter(Mandatory=$false)]
    [int]$monthInterval,
    [Parameter(Mandatory=$true)]
    [string]$scheduleName
)
 
$duration = New-TimeSpan -Hours $durationHours
$schedule = New-AzAutomationSchedule -ResourceGroupName $resourceGroup `
                                                      -AutomationAccountName $automationAccount `
                                                      -Name $scheduleName `
                                                      -StartTime $startTime `
                                                      -DaysOfMonth $DaysofMonth `
                                                      -MonthInterval $monthInterval `
                                                      -ForUpdateConfiguration
 
    New-AzAutomationSoftwareUpdateConfiguration -ResourceGroupName $resourceGroup `
                                                     -AutomationAccountName $automationAccount `
                                                     -Schedule $schedule `
                                                     -Windows `
                                                     -NonAzureComputer $group `
                                                     -IncludedUpdateClassification Critical `
                                                     -Duration $duration
}
