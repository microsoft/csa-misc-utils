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

$workspaceId = "Log Analytics workspace ID goes here"
$scriptBlock = .{
$serverinfo = Get-Content -Path "C:\temp\servergrouping.csv" | ConvertFrom-Csv
$query = "Heartbeat | summarize arg_max(TimeGenerated, *) by SourceComputerId | top 500000 by Computer asc"
$queryResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $workspaceId -Query $query
$queryResults.Results
$servers = $queryResults.Results | Select-Object -ExpandProperty Computer
}
$group1 = @()
$group2 = @()
$group3 = @()

ForEach($server in $serverinfo) 
{
        Switch ($server.patchSchedule){
            'patch_schedule01' {
                $new1 = $servers | ? {$_ -eq $server.servername} | Select-Object -First 1
                $group1+=$new1
            }
            'patch_schedule02' {
                $new2 = $servers | ? {$_ -eq $server.servername} | Select-Object -First 1
                $group2+=$new2
            }
            'patch_schedule03' {
                $new3 = $servers | ? {$_ -eq $server.servername} | Select-Object -First 1
                $group3+=$new3
            }
        }
}
