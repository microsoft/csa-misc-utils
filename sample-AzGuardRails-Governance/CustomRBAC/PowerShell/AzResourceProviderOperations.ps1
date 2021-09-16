# Exports a list of all Azure Provider Operations to a CSV file.
Get-AzResourceProviderOperation -OperationSearchString * | Select Operation,OperationName,ProviderNamespace,Description `
| Export-Csv c:\Scripts\CustomRBAC\resourceprovideractions.csv -nti

# Working examples to drill deeper into specific provider namespaces.
Get-AzResourceProvider | Select ProviderNameSpace | Export-Csv C:\Scripts\CustomRBAC\ResourceProviders.csv -nti

Get-AzResourceProviderOperation -OperationSearchString Microsoft.Automation/* `
| Select Operation,OperationName,Description | Export-Csv C:\Scripts\CustomRBAC\Automation.csv -nti

Get-AzResourceProviderOperation -OperationSearchString Microsoft.Compute/* `
| Select Operation,OperationName,Description | Export-Csv C:\Scripts\CustomRBAC\Compute.csv -nti

Get-AzResourceProviderOperation -OperationSearchString Microsoft.HDInsight/* `
| Select Operation,OperationName,Description | Export-Csv CC:\Scripts\CustomRBAC\HDInsight.csv -nti

Get-AzResourceProviderOperation -OperationSearchString Microsoft.insights/* `
| Select Operation,OperationName,Description | Export-Csv C:\Scripts\CustomRBAC\insights.csv -nti

Get-AzResourceProviderOperation -OperationSearchString Microsoft.Network/* `
| Select Operation,OperationName,Description | Export-Csv C:\Scripts\CustomRBAC\Network.csv -nti

Get-AzResourceProviderOperation -OperationSearchString Microsoft.OperationalInsights/* `
| Select Operation,OperationName,Description | Export-Csv C:\Scripts\CustomRBAC\OpsInsights.csv -nti

Get-AzResourceProviderOperation -OperationSearchString Microsoft.OperationsManagement/* `
| Select Operation,OperationName,Description | Export-Csv CC:\Scripts\CustomRBAC\OpsMgmt.csv -nti

Get-AzResourceProviderOperation -OperationSearchString Microsoft.Sql/* `
| Select Operation,OperationName,Description | Export-Csv C:\Scripts\CustomRBAC\SQL.csv -nti

Get-AzResourceProviderOperation -OperationSearchString Microsoft.Storage/* `
| Select Operation,OperationName.Description | Export-Csv C:\Scripts\CustomRBAC\Storage.csv -nti

Get-AzResourceProviderOperation -OperationSearchString Microsoft.Resources/* `
| Select Operation,OperationName,Description | Export-Csv C:\Scripts\CustomRBAC\Resources.csv -nti

Get-AzResourceProviderOperation -OperationSearchString '*' | ? { $_.Operation -like 'Microsoft.Network/*' } `
| select Operation,OperationName,Description | Out-File azure-network-permissions.txt
