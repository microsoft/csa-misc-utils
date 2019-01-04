## Blob Sync PowerShell Workflow

I constructed this solution for a customer of mine needing to replicate files an application they had in multiple regions.  While [geo-replicated storage](https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy), a component feature of Azure keeping data synced across regions, would provide some level of redundancy it did not protect against accidental user errors in the customer's application where data was removed nor does geo-replicated storage allow you to select the specific region data is replicated to. 

What we needed was fine-grained control over which containers (folders) needed to be replicated to another region and to have complete control over which region we copied the contents to.  A simple PowerShell script would work well to copy small amounts of data; but when the number and sizes of blobs grows this becomes a challenge to detect updates/additions/deletions and make reflective changes in the destination.  Another requirement was this be automatic and hands-off -- also not requiring a workstation or server to run the script from.  The workflow will recursively walk through the folder structure of the specified container and copy everything!

The solution ended up being an [Azure Automation Workflow](https://docs.microsoft.com/en-us/azure/automation/automation-powershell-workflow) that has some benefits of being 'put to sleep' if it exceeds runtime execution limits provided by the Automation facilities.  When it resumes, because it persisted state on what iteration it was on on each run, it will pick up where it left off. 

 #  Details:
Note: Currently I have the source/destination keys stored within the workflow as variables to make this easier to borrow and test for your use-case inside/outside of Azure Automation.  A better solution in a production scenario is to use [Azure Automation Credential assets](https://docs.microsoft.com/en-us/azure/automation/automation-credentials)  

Key variables:

* $containerName - Name of the source/destination containers -- current logic will mimic the structure
* $Srcstorageaccountkey - Storage Account key of the Source account
* $srcStorageAccount    - Source Storage Account
* $deststorageAccount   - Destination Storage account
* $DestAccountKey       - Destination storage account key
* $MaxReturn            - This 'pulls' "N" blobs at a time on each iteration into an array to walk through.  If this is set to a large value, should Azure Automation kill the workflow the script will start over at the last block of "N".  For instance, if you had it set to 800, and it was on the 2nd iteration/loop (already completed 800 previously) and 50% through (400 files), it would actually start processing again 800 files deep into the container and not 1200 files in as the state was saved at the beginning of the 2nd run.


Data Deletion:
The workflow also supports deleting data from the destination if removed from the source.  Use this carefully as it will destroy all copies of your blob!

 `        ForEach  -parallel -ThrottleLimit 25  ($SrcBlob in $SrcBlobs) {
            
            #check to see if the file was removed from source and, if so, remove from destination
            #uncomment this block noting it will be destructive to backup blobs in the destination
            #$removed = $false;
            #if(!$DestBlobsHash.ContainsKey($SrcBlob.Name)){
            #    $removed = $true
            #}

            #if($removed){
            #     $blobToCopy = $SrcBlob.Name
            #     "  -- blob: $blobToCopy in backup store but deleted from primary"
            #     $workflow:FilesDeleted++  
            # }`

* [Details on Azure Automation Runbook limits](https://docs.microsoft.com/en-us/azure/automation/automation-runbook-execution).
