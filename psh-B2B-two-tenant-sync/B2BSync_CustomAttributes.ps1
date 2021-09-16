
$Extensions = @()

#build generic graph URL with filter
function Get-GraphUrl {
    param 
    (
    [Parameter(Mandatory=$true)]
    [string]$UrlFunction,

    [Parameter(Mandatory=$false)]
    [string]$Filter = "",

    [Parameter(Mandatory=$false)]
    [string]$Select = ""
    )
    $hasParm=$false
    $res = "https://graph.windows.net/$SourceTenantId/$($UrlFunction)"

    if ($Filter.Length -gt 0) {
        $Filter = [uri]::EscapeDataString($Filter)
        $res += "?`$filter=" + $Filter
        $hasParm = $true;
    }

    if ($Select.Length -gt 0) {
        $tag = If ($hasParm) { "&" } else { "?" };
        $Select = [uri]::EscapeDataString($Select)
        $res += "$($tag)`$select=" + $Select
        $hasParm = $true;
    }
    $tag = If ($hasParm) { "&" } else { "?" };
    return $res + "$($tag)api-version=1.6"
}

#Update value of custom user attribute in source tenant
function Set-CustomUserAttr {
    param (
        [Parameter(Mandatory=$true)]
        [string]$UserOID,

        [Parameter(Mandatory=$true)]
        [string]$Attribute,

        [Parameter(Mandatory=$true)]
        [object]$Value
    )
    $attr = Get-Attr($Attribute)
    
    $Headers = @{Authorization = "Bearer $SourceTokenAADGraph"}

    $url = "https://graph.windows.net/$SourceTenantId/users/$($UserOID)?api-version=1.6"
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

#get generated attribute name from assigned name
function Get-Attr {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Attribute
    )
    if ($Global:Extensions.Count -eq 0) {
        $Global:Extensions = Get-Extensions
    }

    $attr = @{}
    foreach($ext in $Global:Extensions) {
        $n = $ext.name.split('_')
        if ($n.Get($n.Count-1) -eq $Attribute) {
            $attr = $ext
            break;
        }
    }
    $attr
}
#get all available extension properties
function Get-Extensions {
    $Headers = @{Authorization = "Bearer $SourceTokenAADGraph"}
    $url = "https://graph.windows.net/$SourceTenantId/getAvailableExtensionProperties?api-version=1.6"
    $body = '{"isSyncedFromOnPremises": false}'
    $list = Invoke-RestMethod -Uri $url -Method Post -Headers $Headers -ContentType "application/json" -Body $body -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }

    $list.value
}

#return user(s) with matching value in an extension attribute
function Get-UserByExtAttr {
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$UserOID,

        [Parameter(Mandatory=$true)]
        [string]$Attribute,

        [Parameter(Mandatory=$true)]
        [object]$Value
    )

    $attr = Get-Attr($Attribute)
    $Headers = @{Authorization = "Bearer $SourceTokenAADGraph"}

    $url = Get-GraphUrl -UrlFunction "users" -Filter "$($attr.name) eq '$Value'"
    $list = Invoke-RestMethod -Uri $url -Method Get -Headers $Headers -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }

    $list.value
}

function Get-GroupWithMembers {
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$GroupId,

        [Parameter(Mandatory=$true)]
        [string]$Attribute
    )

    $attr = Get-Attr($Attribute)
    $Headers = @{Authorization = "Bearer $SourceTokenMSGraph"}

    $url = "https://graph.microsoft.com/v1.0/groups/$GroupId/members"
    $list = Invoke-RestMethod -Uri $url -Method Get -Headers $Headers -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }

    $arr = $list.value.GetEnumerator() |%{$_.id};

    $Members = @()
    ForEach ($user in $arr) {
        $u = "https://graph.microsoft.com/v1.0/users/$($user)?`$select=id,DisplayName,userPrincipalName,Surname,GivenName,$attr,mail"
        $r2 = Invoke-RestMethod -Uri $u -Method Get -Headers $Headers -ErrorVariable Failed -ErrorAction SilentlyContinue
        $Members += $r2
    }
    return $Members
}


#return user(s) with matching value in an extension attribute
function New-AppExtAttrFromSettings {
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$AppObjId
    )

    $Headers = @{Authorization = "Bearer $DestTokenAADGraph"}

    $url = "https://graph.windows.net/$DestTenantId/applications/$AppObjId/extensionProperties?api-version=1.6";
    $body=@"
    {
    "name": "$CustomOIDAttributeName",
    "dataType": "String",
    "targetObjects": [
        "User"
    ]
}
"@
    $list = Invoke-RestMethod -Uri $url -Method POST -ContentType "application/json" -Body $body -Headers $Headers -ErrorVariable Failed -ErrorAction SilentlyContinue
    if ($Failed -ne $null) {
        $Failed
        return
    }

    $list.value
}
