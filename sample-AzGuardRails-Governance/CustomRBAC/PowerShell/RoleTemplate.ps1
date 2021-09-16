# Provides a baseline template to work off with an existing builtin role for the custom role.
Get-AzRoleDefinition -Name "Network Contributor" | ConvertTo-Json | Out-File "C:\ScriptOutputs\NetworkContributor.json"
