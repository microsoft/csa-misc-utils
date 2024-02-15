Workflow blobSync {   
    $PSDisableSerializationPreference = $true
    $MaxReturn = 800;
    [int64]$Total = 0;
    [int64]$FilesDeleted = 0;
    $Token = $null;
    [int64]$FilesTransferred = 0;
    [int64]$FilesTransferSuccess = 0;
    [int64]$FilesTransferFail = 0;
    $runflag = $TRUE;
    [string]$containerName = 'myContainer'
    $srcStorageAccount = "sourcestorageaccountname";
    $deststorageAccount = "destinationstorageaccountname";

    Connect-AzAccount -Identity

    $TimeStart = Get-Date -format HH:mm:ss
    "Destination Array Population...";
    $DestBlobsHash = @{};
    $DestBlobsHash = InlineScript
    {
        $DestBlobsHashTemp = @{}
        $destContext = New-AzStorageContext -StorageAccountName $using:deststorageAccount
           
        Get-AzStorageBlob -Context $destContext -Container $using:containerName -ContinuationToken $Token  | 
            Select-Object -Property Name, LastModified, ContinuationToken  | 
            ForEach { $DestBlobsHashTemp[$_.Name] = $_.LastModified.UtcDateTime };
        $DestBlobsHashTemp ; 
    }

    DO {
        "Saving State...";    
        Checkpoint-Workflow  #on each iteration persist our state  
        "Source Array Population...";     
        $SrcBlobs = InlineScript
        {
            $sourceContext = New-AzStorageContext -StorageAccountName $Using:srcStorageAccount
            $SrcBlobs = Get-AzStorageBlob -Context $sourceContext -Container $Using:containerName -MaxCount $using:MaxReturn  -ContinuationToken $using:Token | 
                Select-Object -Property Name, LastModified, ContinuationToken;

            if ($SrcBlobs -ne $null) {
                $cnt = $SrcBlobs.Count;
                write-host "  ** Files Found: $cnt - Pulling $using:MaxReturn files at a time...";
            }

            $SrcBlobs;
        }

        $Total += $SrcBlobs.Count

        if ($SrcBlobs.Length -le 0) { 
            $runflag = $false;
        }
        $Token = $SrcBlobs[$SrcBlobs.Count - 1].ContinuationToken;


        ForEach  -parallel -ThrottleLimit 25  ($SrcBlob in $SrcBlobs) {
            
            #check to see if the file was removed from source and, if so, remove from destination
            #uncomment this block noting it will be destructive to backup blobs in the destination
            <#
            $removed = $false;
            if(!$DestBlobsHash.ContainsKey($SrcBlob.Name)){
                $removed = $true
            }

            if($removed){
                 $blobToCopy = $SrcBlob.Name
                 "  -- blob: $blobToCopy in backup store but deleted from primary"
                 $workflow:FilesDeleted++  
            }
            #>
            # search  in destination blobs for the source blob and unmodified, if found copy it
            $CopyThisBlob = $false

            if ($SrcBlob.Name -eq $null) {
                "SrcBlob name is Null?";
            }
            elseif ($DestBlobsHash.count -eq 0) {
                $CopyThisBlob = $true
            }
            elseif (!($DestBlobsHash.Contains($SrcBlob.Name))) {
                $CopyThisBlob = $true
            }
            elseif ($SrcBlob.LastModified.UtcDateTime -gt $DestBlobsHash.Item($SrcBlob.Name)) {
                $CopyThisBlob = $true
            }

            if ($CopyThisBlob) {
                #Start copying the blobs to destination container
                [string]$blobToCopy = $SrcBlob.Name
                $UtcTime = Get-Date;
                "  ++ Copying: $blobToCopy - " + $UtcTime.ToUniversalTime();
                $workflow:FilesTransferred++;
                try {
                    inlinescript {
                        $destContext = New-AzStorageContext -StorageAccountName $using:deststorageAccount
                        $sourceContext = New-AzStorageContext -StorageAccountName $using:srcStorageAccount
                        $c = Start-AzStorageBlobCopy -SrcContainer $using:containerName -SrcBlob $using:blobToCopy -DestContainer $using:containerName -DestBlob $using:blobToCopy -SrcContext $sourceContext -DestContext $destContext -Force
                    }
                    $workflow:FilesTransferSuccess++;
                }
                catch {
                    Write-Error "$using:blobToCopy transfer failed"
                    $workflow:FilesTransferFail++;
                }   
            }           
        }
    }
    While (($Token -ne $Null) - ($runflag -eq $TRUE))
    
    $TimeEnd = Get-Date -format HH:mm:ss
    $TimeDiff = New-TimeSpan $TimeStart $TimeEnd
    if ($TimeDiff.Seconds -lt 0) {
        $Hrs = ($TimeDiff.Hours) + 23
        $Mins = ($TimeDiff.Minutes) + 59
        $Secs = ($TimeDiff.Seconds) + 59 
    }
    else {
        $Hrs = $TimeDiff.Hours
        $Mins = $TimeDiff.Minutes
        $Secs = $TimeDiff.Seconds 
    }
    $Difference = '{0:00}:{1:00}:{2:00}' -f $Hrs, $Mins, $Secs
   
    "Total blobs in container $container : $Total"
    "Total files transferred: $FilesTransferred"
    #"Total files Deleted: $FilesDeleted"
    "Transfered successfully: $FilesTransferSuccess"
    "Transfer failed: $FilesTransferFail"
    "Elapsed time: $Difference `n"
} 
