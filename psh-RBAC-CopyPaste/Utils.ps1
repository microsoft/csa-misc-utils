function LoginToAAD {
    #force context to grab a token for graph
    Get-AzureRmADUser -UserPrincipalName $ctx.Context.Account.Id
    $AppId = "1950a258-227b-4e31-a9cf-717495945fc2"
    $Resource = "https://graph.windows.net/"

    $cachedTokens = $ctx.Context.TokenCache.ReadItems() `
            | where { $_.TenantId -eq $ctx.Context.Tenant.Id -and ($_.Resource -eq $Resource) -and ($_.DisplayableId -eq $ctx.Context.Account.Id) } `
            | Sort-Object -Property ExpiresOn -Descending

    $token = $cachedTokens[0]

    $ac = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new("$($ctx.Context.Environment.ActiveDirectoryAuthority)$($ctx.Context.Tenant.Id)",$token)
    $token = $ac.AcquireTokenByRefreshToken($token.RefreshToken, $AppId, $Resource)
    $aad = Connect-AzureAD `
        -AadAccessToken $token.AccessToken `
        -AccountId $ctx.Context.Account.Id `
        -TenantId $ctx.Context.Tenant.Id  `
        -ErrorAction Stop
}

function HasDuplicates {
    param (
        [Parameter(Mandatory=$true)]
        $ArrayToTest
    )

    $hasDupes = $false
    $dupList = @()

    foreach($item in $ArrayToTest) {
        $dupItem = $ArrayToTest | where { ($_.ObjectId -ne $item.ObjectId) -and ($_.DisplayName -ne $item.DisplayName) }

        if ($dupItem -ne $null) {
            $hasDupes = $true
            $dupList += @{
                "item1" = $item;
                "item2" = $dupItem;
            }
        }
    }
    return @{
        "hasDupes" = $hasDupes
        "dupItems" = $dupList
    }
}

function GetSPPassword {
    $bytes = New-Object Byte[] 32
    $rand = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rand.GetBytes($bytes)
    $rand.Dispose()
    $clear = [System.Convert]::ToBase64String($bytes)
    return $clear;
}

function CreateSP
{
    param (
        [Parameter(Mandatory=$true)]
        $DisplayName,
        [Parameter(Mandatory=$true)]
        $Tenant
    )

    $pw = GetSPPassword
    $spSecAdminPassword = ConvertTo-SecureString $pw -AsPlainText -Force -ErrorAction Stop
    $guid = [System.Guid]::NewGuid()
    $app = AzureAD\New-AzureADApplication `
            -DisplayName $DisplayName `
            -IdentifierUris "https://$Tenant/$guid" `
            -ErrorAction Stop

    New-AzureRmADAppCredential -ApplicationId $app.AppId -Password $spSecAdminPassword

    $sp = AzureAD\New-AzureADServicePrincipal -AppId $app.AppId -DisplayName $app.DisplayName
    return @{
        "App" = $app
        "SP" = $sp
        "ClearPW" = $pw
    }
}

function GetManifestFromObject
{
    param (
        [Parameter(Mandatory=$true)]
        $DisplayName,
        [Parameter(Mandatory=$true)]
        $Tenant
    )


}

function progress
{
    param (
        [Parameter(Mandatory=$true)]
        [int]$Current,
        [Parameter(Mandatory=$true)]
        [int]$Total
    )

    $donepercent = [int](($Current / $Total) * 100)
    Write-Progress -Activity "Moving items..." -PercentComplete $donepercent -Status "$($donepercent)% complete ($Current of $Total)"
}
