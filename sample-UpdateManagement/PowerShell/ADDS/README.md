<b>PowerShell Scripts - Explained</b> 
<br><br>1) 01-InitialTask-ADDSSecurityGroups.ps1 - Initially imports ActiveDirectory PowerShell module, iterates through
all servers that are domain joined, and groups based upon a patch schedule listed inside a json file sitting in a 
specific directory.
<br><br>2)  02-SchedTask-ADDSSecurityGroups.ps1 - As a scheduled task, imports ActiveDirectory PowerShell module, iterates through
new servers that are domin joined, and groups based upon a patch schedule listed inside a json file sitting in a specific
directory.
