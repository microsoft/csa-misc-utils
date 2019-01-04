function getAuthHeader() {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ClientID,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$ClientKey,
        [Parameter(Mandatory=$true, Position=2)]
        [string]$TenantID
    )

    $AADURI = "https://login.microsoftonline.com/$TenantID/oauth2/token"
    $GrantBody = "grant_type=client_credentials&client_id=$ClientID&client_secret=$ClientKey&resource=https://graph.microsoft.com"

    $AADTokenResponse = Invoke-RestMethod -Uri $AADURI -ContentType "application/x-www-form-urlencoded" -Body $GrantBody -Method Post
    return $AADTokenResponse.access_token
}

function SendMessage(){
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
        [string]$SenderEmail
    )

    $AADToken=getAuthHeader -ClientID $ClientID -ClientKey $ClientKey -TenantID $TenantID
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
    $message.message.toRecipients
    $body = ConvertTo-Json $message -Depth 5
    $SendMail="https://graph.microsoft.com/v1.0/users/{0}/sendMail" -f [uri]::EscapeDataString($senderAccountName)
    $res = Invoke-WebRequest -Uri $SendMail -Method Post -Headers $Headers -Body $body -ContentType "application/json"
}

#variables
$SenderAccountName = "[Sending Account Email]"
$ClientID          = "[Azure AD App Registration]" 
$ClientKey         = "[App Registration Secret]"
$TenantID          = "[Azure AD Tenant ID]"
$Recipient         = "[Email Recipient]"

#execute
SendMessage `
    -Subject "Testing Encryption" `
    -Body "Sending this from Powershell via EXO, using a service principal with app permissions to send behalf of, and specifying an email account I created in my demo O365 subscription." `
    -Recipient $Recipient `
    -ClientID $ClientID `
    -ClientKey $ClientKey `
    -TenantID $TenantID `
    -SenderEmail $SenderAccountName

