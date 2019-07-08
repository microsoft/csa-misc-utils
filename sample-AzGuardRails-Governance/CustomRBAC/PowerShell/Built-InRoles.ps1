# Grabs all Azure Resource Manager builtin role definitions, selects the name + description, then exports the results as a csv.
Get-AzRoleDefinition | Select-Object Name, Description | Export-Csv c:\Scripts\allArmRoles.csv -NTI
