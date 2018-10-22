$Tenant = "myb2ctenant.onmicrosoft.com"
$Headers = @{ "Authorization" = "Bearer $token"}

$Extensions = @()

#build generic graph URL with filter
function Get-GraphUrl {
    param 
    (
    [Parameter(Mandatory=$true)]
    [string]$UrlFunction,

    [Parameter(Mandatory=$false)]
    [string]$Filter = ""
    )
    $Filter = [uri]::EscapeDataString($Filter)
    return "https://graph.windows.net/$Tenant/$($UrlFunction)?`$filter=$Filter&api-version=1.6"
}

#Get Local B2C Tenant accounts
function Get-B2CLocalUsers {
    $url = Get-GraphUrl -UrlFunction "users" -Filter "creationType eq 'LocalAccount'"
    $list = Invoke-WebRequest -Uri $url -Method Get -Headers $Headers -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }

    $res = ConvertFrom-Json $list.Content
    $res.value
}

#return all users (Local, Social, and Native) from the tenant
function Get-AllTenantUsers {
    $url = Get-GraphUrl -UrlFunction "users"
    $list = Invoke-WebRequest -Uri $url -Method Get -Headers $Headers -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }

    $res = ConvertFrom-Json $list.Content
    $res.value
}

#return all app registrations from the tenant
function Get-Apps {
    $url = "https://graph.windows.net/$Tenant/applications?api-version=1.6"
    $list = Invoke-WebRequest -Uri $url -Method Get -Headers $Headers -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }

    $res = ConvertFrom-Json $list.Content
    $res.value
}

#get all available extension properties
function Get-Extensions {
    $url = "https://graph.windows.net/$Tenant/getAvailableExtensionProperties?api-version=1.6"
    $body = '{"isSyncedFromOnPremises": false}'
    $list = Invoke-WebRequest -Uri $url -Method Post -Headers $Headers -ContentType "application/json" -Body $body -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }

    $res = ConvertFrom-Json $list.Content
    $res.value
}

#return a B2C Local user
function Get-B2CLocalUser {
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$SignInId
    )

    $url = Get-GraphUrl -UrlFunction "users" -Filter "signInNames/any(x:x/value eq '$SignInId')"
    $list = Invoke-WebRequest -Uri $url -Method Get -Headers $Headers -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }

    $res = ConvertFrom-Json $list.Content
    $res.value
}

#return B2C user(s) with matching value in an extension attribute
function Get-B2CUserByExtAttr {
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Login,

        [Parameter(Mandatory=$true)]
        [string]$Attribute,

        [Parameter(Mandatory=$true)]
        [object]$Value
    )

    $attr = Get-Attr($Attribute)

    $url = Get-GraphUrl -UrlFunction "users" -Filter "$($attr.name) eq '$Value'"
    $list = Invoke-WebRequest -Uri $url -Method Get -Headers $Headers -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }

    $res = ConvertFrom-Json $list.Content
    $res.value
}

#get generated attribute name from assigned name
function Get-Attr {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Attribute
    )
    if ($Extensions.Count -eq 0) {
        $Extensions = Get-Extensions
    }

    $attr = @{}
    foreach($ext in $Extensions) {
        $n = $ext.name.split('_')
        if ($n -eq $Attribute) {
            $attr = $ext
            break;
        }
    }
    $attr
}

#Update value of custom user attribute
function Set-CustomUserAttr {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Login,

        [Parameter(Mandatory=$true)]
        [string]$Attribute,

        [Parameter(Mandatory=$true)]
        [object]$Value
    )
    $attr = Get-Attr($Attribute)
    
    $B2CUser = Get-B2CLocalUser -SignInId $Login

    $url = "https://graph.windows.net/$Tenant/users/$($B2CUser.userPrincipalName)?api-version=1.6"
    $message = @{
        $attr.name = "$Value";
    }
    $body = ConvertTo-Json $message
    $res = Invoke-WebRequest -Uri $url -Method Patch -Headers $Headers -Body $body -ContentType "application/json" -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }

    return ($res.StatusCode -eq 204)
}

#Update value of standard user attribute
function Set-UserAttr {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Login,

        [Parameter(Mandatory=$true)]
        [string]$Attribute,

        [Parameter(Mandatory=$true)]
        [object]$Value
    )
    $B2CUser = Get-B2CLocalUser -SignInId $Login

    $url = "https://graph.windows.net/$Tenant/users/$($B2CUser.userPrincipalName)?api-version=1.6"
    $message = @{
        $Attribute = "$Value";
    }
    $body = ConvertTo-Json $message
    $res = Invoke-WebRequest -Uri $url -Method Patch -Headers $Headers -Body $body -ContentType "application/json" -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }
    return ($res.StatusCode -eq 204)
}

<#

$users = Get-AllTenantUsers

$users = Get-B2CLocalUsers

$user = Get-B2CLocalUser -SignInId "joe@example.com"

$apps = Get-Apps

$extensions = Get-Extensions

$attr = Get-Attr -Attribute "ShoeSize"

Set-CustomUserAttr -Login "joe@example.com" -Attribute "ShoeSize" -Value "12"

Set-UserAttr -Login "joe@example.com" -Attribute "postalCode" -Value "12345"

Get-B2CUserByExtAttr -Login "joe@example.com" -Attribute "ShoeSize" -Value "12"

#>
