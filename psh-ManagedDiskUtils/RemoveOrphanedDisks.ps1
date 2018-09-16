<#
    .SYNOPSIS
        (ARM) Delete orphaned / unlocked .vhd blobs from a subscription.

    .DESCRIPTION 
        The script will give a choice to filter for orphaned disks by 
        storage accounts in a designated resource group OR all storage
        accounts in the entire subscription. 

	1.	Get a list of all VMs (per RG or entire subscription)
	2.	Get all disks attached to those VMs and organizing them by data and OS disks
	3.	Get a separate list of all .vhds in all containers in all storage accounts (per RG or entire subscription)
	4.	Iterate through the .vhds list, checking if you already have the disk in your other collections (i.e. attached to a VM) and, only if you don’t, then you add it to the ‘orphaned disks collection’
	5.	Given the option to delete those orphaned disks


    .OUTPUT
        Display a list of all orphaned .vhd blobs in a resource group or
        all resource groups in a subscription. You can then choose to 
        delete ALL identified orphaned blobs or choose to exit the script.

#>

# =======================================================================================
# Parameters
# =======================================================================================

Param(

    [Parameter(Mandatory=$false)] 
	[string]$SubscriptionName, # Mandatory

    [Parameter(Mandatory=$false)] 
	[string]$SubscriptionId, # Mandatory (optional if using $SubscriptionName)

    [Parameter(Mandatory=$false)] 
	[string]$ResGroup
)


# =======================================================================================
# (Optional) Update ARM modules
# =======================================================================================
#Install-Module AzureRM
#Install-AzureRM
#Install-Module Azure
#Import-AzureRM
#Import-Module Azure

# =======================================================================================
# Authenticate to Azure
# =======================================================================================

Write-Host "Log in to your Azure subscription..." -ForegroundColor Green
#Login-AzureRmAccount
#Get-AzureRmSubscription -SubscriptionName $SubscriptionName | Select-AzureRmSubscription
#Set-AzureRmContext -SubscriptionId $SubscriptionId
#Set-AzureRmContext -SubscriptionId ae7ea058-b5a7-44c2-91cf-ac6ee0389448 

# =======================================================================================
# Functions
# =======================================================================================

Function Message ($caption, $message) {
    $yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes","help"
    $no = new-Object System.Management.Automation.Host.ChoiceDescription "&No","help"
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
    $answer = $host.ui.PromptForChoice($caption,$message,$choices,0)
    Write-Output $answer
}

Function FindOrphanedDisks ($ResGroup) {    
        
    Write-Host ""
    Write-Host "Obtaining list of disks your VMs are currently using..." -ForegroundColor Yellow

    # Empty variables
    $TransformedDisksArray = [System.Collections.ArrayList]@()
    $TransformedOSDisks = ""
    $TransformedVMDataDisks = ""
    $VMDataDisks = ""

    If ($ResGroup) {
        $VMDiskInfo = Get-AzureRmVM -ResourceGroupName $ResGroup | Select-Object -Property StorageProfile
    } Else {
        $VMDiskInfo = Get-AzureRmVM | Select-Object -Property StorageProfile
    }

    
    $VMDataDisks = $VMDiskInfo.StorageProfile.DataDiskNames
    $VMOSDisks = $VMDiskInfo.StorageProfile.osDisk.vhd.uri

    # For each VM, get a list of the OS disks
    Foreach ($os in $VMOSDisks) {
        $TransformedDisksTmp = $TransformedDisksArray.Add($os.Split("/")[4])    
    }     
  
    # For each VM, get a list of DataDiskNames
    $TransformedDisksTmp = [System.Collections.ArrayList]@() 
    $TransformedDataDisks = foreach ($i in $VMDataDisks) {

        ($i + ".vhd").ToLower()
    }
    Foreach ($datadisk in $TransformedDataDisks){
        $TransformedDisksTmp = $TransformedDisksArray.Add($datadisk)
    }

    # For each SA, obtain the corresponding KEY
    $hListofStorageKeys = @{}

    If ($ResGroup) {
        $FilteredSAs = Get-AzureRmStorageAccount -ResourceGroupName $ResGroup | Select-Object -Property StorageAccountName, ResourceGroupName
    } Else {
        $FilteredSAs = Get-AzureRmStorageAccount | Select-Object -Property StorageAccountName, ResourceGroupName
    }

    $sacount = @($FilteredSAs).Count - 1
    $x = 0
    while ($x -le $sacount) {
        $FilteredSAKey = Get-AzureRmStorageAccountKey -ResourceGroupName @($FilteredSAs)[$x].ResourceGroupName -Name @($FilteredSAs)[$x].StorageAccountName
        $hListofStorageKeys.Add(@($FilteredSAs)[$x].StorageAccountName, $FilteredSAKey[0].Value)
        write-host "Adding Storage acocunt: " @($FilteredSAs)[$x].StorageAccountName " to search list..." -ForegroundColor Cyan
        $x = $x + 1
    }

    # Create a context for each SA / KEY pair
    Write-Host ""
    Write-Host "Accessing storage accounts within specified resource group..." -ForegroundColor Yellow

    $objTotal = [System.Collections.ArrayList]@() 
    $preobjTotal = [System.Collections.ArrayList]@() 
  
    foreach ($i in $hListofStorageKeys.Keys) {
        $StorageAccountName = $i
        $StorageAccountKey = $hListofStorageKeys.Item($i)
        $ContextName = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
        $Containers = Get-AzureStorageContainer -Context $ContextName | Select-Object -ExpandProperty Name
        $containercount = @($Containers).Count - 1     

        foreach ($x in $Containers) {
            $CurrentContainer = $x
            write-host "Searching for orphaned VHDs in Container: " $x -ForegroundColor Yellow
            $CurrentContext = $ContextName               
            $ListofDisks = Get-AzureStorageBlob -Container $x -Context $CurrentContext | Select-Object -ExpandProperty Name

            foreach ($disk in $ListofDisks) {                        
                if ($disk -like '*.vhd'){
                    if ($TransformedDisksArray -contains $disk){
                    } else {
                        $preobjAverage = New-Object System.Object
                        $preobjAverage | Add-Member -type NoteProperty -name DiskName -value $disk
                        $preobjAverage | Add-Member -type NoteProperty -name ContainerName -Value $CurrentContainer
                        $preobjAverage | Add-Member -type NoteProperty -name Context -Value $CurrentContext
                        $preobjTotal.Add($preobjAverage) | Out-Null
                        write-host "   * Found Orphaned VHD: " $disk -ForegroundColor DarkYellow
                       # write-host $preobjTotal[0].DiskName
                    }
                } 
            }
            $containercount = $containercount - 1                      
        }    

    }
    
    write-host ""   
    #Write-Output $preobjTotal
    return $preobjTotal
}
       
# =======================================================================================
# Script Body
# =======================================================================================

Write-Host ""
Write-Host "Running script 'Find Orphaned Resources in Subscription'..." -ForegroundColor Green
Write-Host ""

If (!$ResGroup) {

    # Filter by Resource Group
    # "Yes" will give a value of 0 to the switch statement
    # "No" will give a value of 1 to the switch statement
    $caption = "Filtering Option"
    $message = "Would you like to filter by resource group?"
    $answerFilterRG = Message -caption $caption -message $message

    If ($answerFilterRG -eq 0) {
        $AllRGs = Get-AzureRmResourceGroup | Select-Object -ExpandProperty ResourceGroupName
        Write-Output ""
        Write-Output "Below is a list of all Resource Groups in the subscription:"
        Write-Output ""
        Write-Output $AllRGs
        Write-Host ""
        $ResGroup = Read-Host "Resource Group Name"

        # Check if resource group exists  
        If ($ResGroup -notin $AllRGs) {
            Write-Host ""
            Write-Host "Sorry, that resource group does not exist. Please type a valid input." -ForegroundColor Red
            Write-Host "See available resource groups below:" -ForegroundColor Red
            $AllRGs
            Write-Host ""
            $ResGroup = Read-Host "Resource Group Name"
        }
    }
}

$ListofOrphanedDisks = [System.Collections.ArrayList]@()

If ($ResGroup) {
    $ListofOrphanedDisks = FindOrphanedDisks -ResGroup $ResGroup
} Else {
    $ListofOrphanedDisks = FindOrphanedDisks
}
        
if (@($ListofOrphanedDisks).Count -eq 0){
    If ($ResGroup ) {
        Write-Host "There are no orphaned disks in the resource group $ResGroup." -ForegroundColor Green
    } Else {
        Write-Host "There are no orphaned disks in this subscription." -ForegroundColor Green
    }
}
Else{
    Write-Host "We have the identified the following orphaned disks in resource group $ResGroup :" -ForegroundColor Green
    $ListofOrphanedDisks | Format-Table
    $DeleteDiskOption = Read-Host "Would you like to: [1] delete all orphaned disks, or [2] continue with the script? Type 1 or 2"

    If ($DeleteDiskOption -eq 1) {

     $diskcount = @($ListofOrphanedDisks).GetUpperBound(0) 
     write-host "Wait While we expunge " @($ListofOrphanedDisks).GetUpperBound(0) " drives" -ForegroundColor Green
     $x = 0
     while ($x -le $diskcount) {
       write-host "  **** Removing " @($ListofOrphanedDisks)[$x].DiskName -ForegroundColor Cyan
       Remove-AzureStorageBlob -Blob @($ListofOrphanedDisks)[$x].DiskName -Container @($ListofOrphanedDisks)[$x].ContainerName -Context @($ListofOrphanedDisks)[$x].Context
       $x = $x + 1
     }

    }

}




