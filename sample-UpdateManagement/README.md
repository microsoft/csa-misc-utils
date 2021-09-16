# Update Management

<i>Sample Code and Documentation to Assist Deployment and Management of On-Premises and AWS Servers</i>

<b><u>Microsoft Documentation</u>:</b>
<br><a href="https://docs.microsoft.com/en-us/powershell/module/azurerm.automation/new-azurermautomationschedule?view=azurermps-6.13.0">Azure Rm Automation Schedule</a>
<br><a href="https://docs.microsoft.com/en-us/powershell/module/azurerm.automation/new-azurermautomationsoftwareupdateconfiguration?view=azurermps-6.13.0">Azure Rm Automation Software Update Configuration</a>
<br><br><b><u>General Troubleshooting</u>:</b><br>1) Ensure Azure Az PowerShell module is completely up to date.<br>2) <a href="https://www.youtube.com/watch?v=6fhvYSgQRwg">Troubleshoot Update Agent Readiness: Not Configured</a>
<br><br><b><u>Troubleshooting MMA Agent</u>:</b>
<br><a href="https://docs.microsoft.com/en-us/azure/automation/troubleshoot/update-agent-issues">Windows Troubleshooting</a> 
<br><a href="https://docs.microsoft.com/en-us/azure/automation/troubleshoot/update-agent-issues-linux">Linux Troubleshooting</a> 
<br><a href="https://docs.microsoft.com/en-us/azure/automation/troubleshoot/hybrid-runbook-worker">Troubleshoot Hybrid Runbook Worker</a>
<br><a href="https://www.powershellgallery.com/packages/Troubleshoot-WindowsUpdateAgentRegistration/1.0">Windows Troubleshooter Tool</a>
<br><a href="https://gallery.technet.microsoft.com/scriptcenter/Troubleshooting-utility-3bcbefe6">Linux Troubleshooter Tool</a>
<br><br><u><b>General Information</u>:</b>
<br>1) As of January 2019, patch groups are limited to 500 servers. If there are more than 500 servers, customers will need to divide into multiple groups.
<br>2) If WSUS is involved with the deployment, Windows looks to WSUS as the control plane with excluded and included patches.
<br>3) Standalone WSUS works well, even if there is a substantial amount of Windows machines.
<br>4) Pay attention to the total number of nodes if using an OMS Gateway. If servers cannot be assessed in the portal underneath Update Management and telneting to the machines over appropriate ports (default is 8081) does not work, plan to build out another OMS Gateway and use a load balancer. The easiest way to course correct is to assign a new static IP address to the first OMS Gateway, assign a new static IP address to the second OMS Gateway, and use the static IP of the first OMS Gateway as your VIP on the load balancer. You will not need to adjust the deployment on all servers' MMA configurations this way.

