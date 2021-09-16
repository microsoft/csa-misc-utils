<b><u>Update Agent Readiness - Explained:</b>
<br>In the portal, the Update Agent Readiness column data is lazy-loaded. Azure checks readiness of every machine individually using the following <a href="https://docs.microsoft.com/en-us/rest/api/automation/hybridrunbookworkergroup/get">REST API</a>. 
<br><br><b>Update Agent Readiness - GET Calls:</b>
<br>The update readiness metric solely checks if the patch agent (System HybridWorker) is registered and actively pinging. Each response code (Ready, Disconnected, Not configured) denotes a specific readiness state within the column.
<br>1) <u>Not Configured</u> - the GET call resolves to 404.
<br>2) <u>Disconnected</u> - The GET call resolves to 200, but lastSeen property value (related to ping time) is older than an hour ago.
<br>3) <u>Ready</u> - The GET call resolves to 200 and the lastSeen property is less than an hour ago. 
<br><br><b>UpdateAgentReadiness Instructions:</b>
<br>1) Run the 01-BearerToken.ps1 while logged into Azure PowerShell with an active account and pointed at the working sub.
<br>2) The 01-BearerToken.ps1 loads the actual Bearer Token into memory. This gets called upon in the UpdateAgentReadiness.ps1
script by way of using Get-AzureRmCachedAccessToken.
<br>3) The 02-UpdateAgentReadiness.ps1 script will output all servers checked into Update Management inside 1 .csv file. Having
this information will be helpful if grouping servers within a patch group. If the server reports as "Not configured" or 
"Disconnected," the patching fails.
