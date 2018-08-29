function getAuthHeader() {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ClientID,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$ClientKey,
        [Parameter(Mandatory=$true, Position=2)]
        [string]$TenantID,
        [Parameter(Mandatory=$true, Position=3)]
        [string]$UserName,
        [Parameter(Mandatory=$true, Position=4)]
        [SecureString]$Password
    )

    $pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))

    $AADURI = "https://login.microsoftonline.com/$TenantID/oauth2/token"
    $GrantBody = "grant_type=password&username=$UserName&password=$pw&resource=https://graph.microsoft.com&client_id=$ClientID&client_secret=$ClientKey"

    $AADTokenResponse = Invoke-RestMethod -Uri $AADURI -ContentType "application/x-www-form-urlencoded" -Body $GrantBody -Method Post
    return $AADTokenResponse.access_token
}

function SendMessage() {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Subject, 
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Body, 
        [Parameter(Mandatory=$true, Position=2)]
        [string]$Recipient,
        [Parameter(Mandatory=$true, Position=3)]
        [string]$ClientID,
        [Parameter(Mandatory=$true, Position=4)]
        [string]$ClientKey,
        [Parameter(Mandatory=$true, Position=5)]
        [string]$TenantID,
        [Parameter(Mandatory=$true, Position=6)]
        [string]$SenderEmail,
        [Parameter(Mandatory=$true, Position=7)]
        [SecureString]$SenderPassword
    )

    $AADToken = getAuthHeader -ClientID $ClientID -ClientKey $ClientKey -TenantID $TenantID -UserName $SenderEmail -Password $SenderPassword
    $Headers = @{Authorization = "Bearer $AADToken"}

    $message = @{
        "message" = @{
            "subject" = $Subject;
            "body" = @{
                "contentType" = "text";
                "content" = $Body;
            };
            "toRecipients" = @(
                @{
                    "emailAddress" = @{
                        "address" = $Recipient;
                    };
                };
            );
        };
        "savedToSentItems" = "false"
    }
    $body = ConvertTo-Json $message -Depth 5
    $SendMail="https://graph.microsoft.com/v1.0/me/sendMail"
    $res = Invoke-WebRequest -Uri $SendMail -Method Post -Headers $Headers -Body $body -ContentType "application/json"
}

#variables
$SenderAccountName = "[Sending Account Email]"
$ClientID          = "[Azure AD App Registration]" 
$ClientKey         = "[App Registration Secret]"
$TenantID          = "[Azure AD Tenant ID]"
$PW                = ConvertTo-SecureString "[Clear text password of sending user account]" -AsPlainText -Force
$Recipient         = "[Email Recipient]"

#execute
SendMessage `
    -Subject "Testing Encryption 2" `
    -Body "Sending this one also from powershell, but authenticating DIRECTLY as the sending user." `
    -Recipient $Recipient `
    -ClientID $ClientID `
    -TenantID $TenantID `
    -ClientKey $ClientKey `
    -SenderEmail $SenderAccountName `
    -SenderPassword $PW
