<b><u>Automated Compliance Reporting:</b></u>
1) Run the 01-BearerToken.ps1 while logged into Azure PowerShell, with an active account pointed at the working sub. 
2) The 01-BearerToken.ps1 script loads the actual Bearer Token into memory. This token gets called upon in the each of the automation scripts by way of using the Get-AzureRmCachedAccessToken function. The bearer token allows the logged in user to hit the API directly to query information. 
3) Each script will run a Log Analytics query against the Update Management environment, whether it be for pre-analysis or post analysis.  
4) In addition, the output of each script will export to a csv file that can be used for regulatory records of patch compliance.
