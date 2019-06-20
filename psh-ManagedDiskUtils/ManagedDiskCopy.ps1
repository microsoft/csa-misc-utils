<#
.SYNOPSIS

Managed disks in Azure have no direct facilitites to access the underlying URL/path the disk resides in since 
they are placed into storage accounts under the hood by Azure.  Often times there's a desire to take a disk from a single
VM and move to another region where you can create a new VM and attach to the disk that's copied.  This script 
provides a means to do that and has been tested as working using the new AZ PowerShell cmdlets.  
If this is run in a PowerShell context without the new AZ cmdlets installed; simply do a search and replace of Az to AzureRM.

Note:  The SOURCE VM needs to be powered off to create the SAS URL and to ensure no writes are occuring to the disk during the copy.

.DESCRIPTION

This script will require you to populate the source resource group and disk name followed by details of a storage account
existing or newly created storage account in the destination region to be used as an intermediate storage location.  Once the disk
is copied, we then create a managed disk pointed at the newly copied VHD; and delete the temporary VHD in the storage account

This script takes advantage of the Grant-AzureRmDiskAccess provding a temporary SAS token to a managed disk. 

It does also require the specified container exist in the destination account

#>

#login-azaccount -- ensure you are logged in and that the context is set to the proper subscription
#Set-azContext -SubscriptionId susbcriptionid

$resourcegroupname="RG"
$stagingstorageaccountname = 'AccountName'
#name of the managed disk to copy
$managedDiskName = 'DiskName'
#temporary file created in a storage account in the destination region
$stagingdiskname='stage.vhd'
#container name to create/copy the source disk into the destination storage account
$stagingstorageaccountContainer = 'vhds'
#resourcegroup that managed disk will be created in and the storage account used to stage the copy resides in
$destResourceGroup = 'DestRG'
$destlocation = 'East US'
$storageType = 'Premium_LRS'
$OSType = 'Windows'

#get a reference to the source disk, generate a temporary SAS to allow us to copy and begin a copy operation
$managedDisk= Get-azDisk -ResourceGroupName $resourcegroupname -DiskName $managedDiskName
$sas = Grant-azDiskAccess -ResourceGroupName $resourcegroupname -DiskName $managedDisk.name  -DurationInSecond 7200 -Access Read

#Getting a context to the destination storage account
$deststorageaccount = Get-AzStorageAccount -Name $stagingstorageaccountname -ResourceGroupName $destResourceGroup
New-AzStorageContainer -Context $deststorageaccount.Context -name $stagingstorageaccountContainer -ErrorAction SilentlyContinue

#create a container by name vhds before starting the copy
$copyfile = Start-AzStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer $stagingstorageaccountContainer -DestContext $deststorageaccount.Context -DestBlob $stagingdiskname -ConcurrentTaskCount 500

#Lets grab the status of any pending copy operations and dwell before we proceed -- 
Get-AzStorageBlob  -Context $deststorageaccount.Context -Container $stagingstorageaccountContainer| ForEach-Object { Get-AzStorageBlobCopyState -Blob $_.Name -Context $deststorageaccount.Context -Container $stagingstorageaccountContainer -WaitForComplete }


#build a path to the storage account resource and the path to the VHD from the items above
$subid = (Get-azContext).Subscription.id
$sourceVHDURI = $deststorageaccount.Context.BlobEndPoint + "/" + $stagingstorageaccountContainer + "/" + $stagingdiskname
$storageAccountId = '/subscriptions/' +$subid + '/resourceGroups/' + $destResourceGroup + '/providers/Microsoft.Storage/storageAccounts/' + $stagingstorageaccountname

$diskConfig = new-azdiskconfig -AccountType $storageType -Location $destlocation -CreateOption Import -StorageAccountId $storageAccountId -SourceUri $sourceVHDURI -OsType $OSType
New-azDisk -Disk $diskConfig -ResourceGroupName $destResourceGroup -DiskName $managedDisk.Name

#release the SAS access token as each disk can only have one and it prevents some operations from occuring on the source disk while active
Revoke-AzDiskAccess -ResourceGroupName $resourcegroupname -DiskName $managedDiskName

#clean up the copied VHD (delete the temporary VHD from the staging storage account to save money -- it's not needed once a new disk is created)
Remove-AzStorageBlob -Blob $stagingdisknamee -Container $stagingstorageaccountContainer -Context $deststorageaccount.Context
