<#
Created 
2018.08.24
Shannon Kuehn
Last Updated

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


## Initial Security Group Assignment                                                                    #
#########################################################################################################
## 
## Script performs the following tasks:
## 1) Imports ActiveDirectory PoSH module.
## 2) Stores all AD DS computers as a variable to loop through.
## 3) Loops through each recently created server to determine if a metadata json file is on the server. 
## 4) If server has a json file saved, server name will be stored as a variable.
## 5) Loops through server name and extracts SamAccountName. SamAccountName is necessary for AD Security 
## Group assignment.
## 6) Formulates a patch schedule based upon json file for each server.
## Notes: 
##  a. Run on server with AD DS role installed or on a server with RSAT tools.
##  b. Test permissions to run (best with a service account): requires permissions to query server 
##  objects in AD DS and ability to assign servers to Security Groups.
#########################################################################################################

Import-Module ActiveDirectory
$servers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
ForEach($server in $servers){
    $path = Test-Path "\\$server\C$\filepath\base.json" 
        If($path -eq $true){
        $patchSchedule = Get-Content -Raw -Path "\\$server\c$\filepath\base.json" | ConvertFrom-Json | Select-Object -ExpandProperty patch_schedule
        $SAMAccountName = Get-ADComputer -Identity $server | Select-Object -ExpandProperty SamAccountName
        $patchScheduleName = ""  
        Switch ($patchSchedule){
            '01'{$patchScheduleName = "patch_schedule_01"}
            '02'{$patchScheduleName = "patch_schedule_02"}
            '03'{$patchScheduleName = "patch_schedule_03"}
            '04'{$patchScheduleName = "patch_schedule_04"}
             }
        Add-ADGroupMember -Identity $patchScheduleName -Members $SAMAccountName       
        }
        }
