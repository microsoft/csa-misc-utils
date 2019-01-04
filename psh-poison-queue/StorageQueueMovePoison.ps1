<#
    Purpose: restore Azure Storage Queue messages from a poison queue back into a primary queue
    Date: 1/3/2019
    Author: Brett Hacker
#>

#Settings
$connectionStr = "[Storage account connection string]"
$destQueueName = "[queue name]"
$srcQueueName = "$destQueueName-poison"

#Path to the "Microsoft.WindowsAzure.Storage" dll (from NuGet)
$storageLibPath = "[local-path-to]\Microsoft.WindowsAzure.Storage.dll"

#Dot-sourced variable override (optional, comment out if not using)
if (Test-Path "$($env:PSH_Settings_Files)StorageQueueMovePoison.ps1") {
    . "$($env:PSH_Settings_Files)StorageQueueMovePoison.ps1"
}

#do not alter below here
[System.Reflection.Assembly]::LoadFrom($storageLibPath) | Out-Null
$storageAccount = [Microsoft.WindowsAzure.Storage.CloudStorageAccount]::Parse($connectionStr);
$client = $storageAccount.CreateCloudQueueClient();
$sourceQ = $client.GetQueueReference($srcQueueName)
$destQ = $client.GetQueueReference($destQueueName)
$count = 0
$toProcess = [int]$sourceQ.ApproximateMessageCount
$donepercent = 0

while ($true) {
    $srcMsg = $sourceQ.GetMessage()
    if ($srcMsg -eq $null) {
        break;
    }
    $destMsg = [Microsoft.WindowsAzure.Storage.Queue.CloudQueueMessage]::new($srcMsg.AsString)
    $destQ.AddMessage($destMsg)
    $sourceQ.DeleteMessage($srcMsg)
    $count++
    $donepercent = [int](($count / $toProcess) * 100)
    Write-Progress -Activity "Moving items..." -PercentComplete $donepercent -Status "$($donepercent)% complete ($count of $toProcess)"
}
""
"$count messages restored"