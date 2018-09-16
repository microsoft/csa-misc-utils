<#
.SYNOPSIS

Managed disks in Azure have no direct facilitites to access the underlying URL/path the disk resides in since 
they are placed into storage accounts under the hood by Azure.  Often times there's a desire to take a generalized VM
from one VM and move to another region -- this script provides a mechanism to do this.

.DESCRIPTION

This script will require you to populate the source resource group and image name followed by details of a storage account
existing or newly created storage account in the destination region to be used as an intermediate storage location.  Once the disk
is copied, we then create an image (Windows OS based in the script) pointed at the newly copied VHD

This script takes advantage of the Grant-AzureRmDiskAccess provding a temporary SAS token to a managed disk. 

It does also require the specified container exist

#>


$sourceResourceGroupName='SourceResourceGroupName'
$sourceImageName='NameOfSourceImageToCopy'

$destconainer = 'containerindestinationstorageaccount'
$destVHDName = 'destinationdisk.vhd'
$destLocation = 'eastus'
$destImageName = 'NewEmageEastUS'
$destResourceGroup = 'DestResourceGroup'
$destStorageAccount = 'destStorageAccountName'
$destStorageAccountKey ='key'

#Validation to ensure container name is lower case
$destconainer = $destconainer.ToLower() 

$sas = Grant-AzureRmDiskAccess -ResourceGroupName $sourceResourceGroupName -DiskName $sourceImageName -DurationInSecond 3600 -Access Read 
$destContext = New-AzureStorageContext –StorageAccountName $destStorageAccount -StorageAccountKey $destStorageAccountKey
Start-AzureStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer $destconainer  -DestContext $destContext -DestBlob  $destVHDName -ConcurrentTaskCount 150 
Get-AzureStorageBlobCopyState -Container $destconainer  -Blob $destVHDName -Context $destContext -WaitForComplete

#build URI to new VHD
$VHDPath=$destContext.StorageAccount.BlobStorageUri.PrimaryUri.AbsoluteUri
$VHDPath=$VHDPath  + $destconainer + "/" + $destVHDName

#create image in destination based on copied VHD
$imageConfig = New-AzureRmImageConfig -Location $destLocation
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType Windows -OsState Generalized -BlobUri $VHDPath
$image = New-AzureRmImage -ImageName $destImageName -ResourceGroupName $destResourceGroup -Image $imageConfig

#clean up the copied VHD
Remove-AzureStorageBlob -Blob $destVHDName -Container $destconainer -Context $destContext

