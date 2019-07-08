<b>Get-AutomationConnection Explained:</b>
<br>Get-AutomationConnection is an internal cmdlet to Azure Automation that allows you to get a relative connection 
from the automation account without going through the Azure Resource Manager APIs. Note that the cmdlet is not 
Get-AzureAutomationConnection (which is the old service management cmdlet) or Get-AzureRMAutomationConnection 
(which is the newer resource manager cmdlet). This interal cmdlet is necessary to ensure you can get a Run As 
Connection to pass to the Connect-AzureRMAccount cmdlet to authenticate to Azure and manage other resources. 
There are other internal cmdlets that are used to retrieve assets, like Get-AutomationVariable, etc.
