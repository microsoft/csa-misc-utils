<#
Created 
2018.12.20 
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

# Fill in local path, Azure subscription ID, resource group, and automation account.
$path = "Local or server file path goes here"
$subId = "Azure subscription ID goes here"
$rg = "Resource Group name goes here"
$automationAccount = "{automation account}"
$bearer = Get-AzureRmCachedAccessToken
$header = @{"Authorization"="Bearer $bearer"}
$hybridWorkerGroups = Get-AzureRmAutomationHybridWorkerGroup -ResourceGroupName $rg -AutomationAccountName $automationAccount
$csv = "MachineName,State,LastSeenTime`r`n"
$file = New-Object -ComObject Scripting.FileSystemObject
$csvFile = $file.CreateTextFile($path,$true)
$csvFile.Write($csv)
$csvFile.Close()

ForEach($hybridworkerGroup in $hybridWorkerGroups){
    $apiCall = "https://management.azure.com/subscriptions/"+$subId+"/resourceGroups/"+$rg+"/providers/Microsoft.Automation/automationAccounts/"+$automationAccount+"/hybridRunbookWorkerGroups/"+$hybridWorkerGroup.Name+"?api-version=2015-10-31"
    $invokeStatus = (Invoke-WebRequest -Uri $apiCall -Headers $header -Method Get)
    $state = ""
    $lastSeenTime = ""
    if($invokeStatus.StatusCode -eq 200)
    {
        $invokeVar = Invoke-RestMethod -Uri $apiCall -Headers $header -Method Get
        $lastSeenDate = Get-Date -Date $invokeVar.hybridRunbookWorkers[0].lastSeenDateTime
        $diffTimeSpan = (Get-Date) - $lastSeenDate
        if($diffTimeSpan.Hours -gt 1)
        {
            $state = "disconnected" 
        }
        else {
            $state = "ready"
        }    
    }
    elseif($invokeStatus.StatusCode -eq 404)
    {
            $state = "not configured"
    }
    else
    {
        $state = "error"    
    }
    $lastSeenTime = $hybridworkerGroup.RunbookWorker.LastSeenDateTime.LocalDateTime.ToShortDateString()+ " " + $hybridworkerGroup.RunbookWorker.LastSeenDateTime.LocalDateTime.ToLongTimeString()
    Add-Content $path "$($hybridworkerGroup.RunbookWorker.Name),$state,$lastSeenTime"            
}
