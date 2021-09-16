<#
    Reset all accessible Azure SQL server firewall to allow access from local IP address.
    An AAD SP is used here and needs at least 'SQL SECURITY MANAGER' role for the managed SQL server instance
    7/19/2018, Brett Hacker
#>

#Settings
$appid = "[SP AppID]"
$appSecret = '[SP secret]'
$tenantId = "[SP tenant]"
#default rule name
$defaultRuleName="[Name of your default rule, like 'HomeLab']"

#dot-source local file to override variables above
if (test-path 'C:\users\brhacke\OneDrive - Microsoft\Documents\WindowsPowerShell\UpdateAllSqlFirewall-mySettings.ps1') {
    . 'C:\users\brhacke\OneDrive - Microsoft\Documents\WindowsPowerShell\UpdateAllSqlFirewall-mySettings.ps1'
}

#-----------------------
#authenticate SP
$SecPw = ConvertTo-SecureString $appSecret -AsPlainText -Force -ErrorAction Stop
$cred = New-Object PSCredential ($appid, $SecPw)
Connect-AzureRmAccount -ServicePrincipal -Credential $cred -TenantId $tenantId

#get list of subscriptions for this SP
$subs = (Get-AzureRmSubscription).Name

#Get current Local IP (free site I'm hosting)
$web = New-Object Net.WebClient
$MyIp = $web.DownloadString("http://pingip.azurewebsites.net/")
$web.Dispose()

#loop the subs
foreach($sub in $subs) {
    Write-Output "Updating SQL Servers in $sub..."

    Set-AzureRMContext -Subscription "$sub"
    $servers = Get-AzureRmSqlServer
    foreach($server in $servers) {
        Write-Output "Updating $server..."

        $rules = Get-AzureRmSqlServerFirewallRule `
            -ResourceGroupName $server.ResourceGroupName `
            -ServerName $server.ServerName

        if (($rules | where { $_.FirewallRuleName -eq $defaultRuleName }).length -eq 0) {
            Write-Output "Adding $defaultRuleName rule..."
            New-AzureRmSqlServerFirewallRule `
                -EndIpAddress $MyIp `
                -FirewallRuleName $defaultRuleName `
                -ResourceGroupName $server.ResourceGroupName `
                -ServerName $server.ServerName `
                -StartIpAddress $MyIp
        } else {
            Write-Output "Updating $defaultRuleName rule..."
            Set-AzureRmSqlServerFirewallRule `
                -EndIpAddress $MyIp `
                -FirewallRuleName $defaultRuleName `
                -ResourceGroupName $server.ResourceGroupName `
                -ServerName $server.ServerName `
                -StartIpAddress $MyIp
        }
    }
}