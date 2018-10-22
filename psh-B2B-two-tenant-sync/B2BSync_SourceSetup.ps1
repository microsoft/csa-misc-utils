<#
Configure SOURCE site - one-time, requires tenant admin to consent to the DEST site service principal
See README.txt for details
#IMPORTANT: edit "B2BSync-MyVars.ps1 and fill in your variables - see README
#>

# Dot-sourcing variables - update "B2BSync-Myvars.ps1 and use that file name
. "$PSScriptRoot\B2BSync-MyVars.ps1"

# Load dialog library
. "$PSScriptRoot\B2BAdminConsentDialog.ps1"

#consent URL (admin loads in browser)
$consentUrl = "https://login.microsoftonline.com/$($SourceTenantId)/oauth2/authorize?response_type=id_token&client_id=$($appID)&redirect_uri=$appReplyUrl&response_mode=form_post&nonce=a4014117-28aa-47ec-abfb-f377be1d3cf6&resource=https://graph.windows.net&prompt=admin_consent"
$result = LoadConsentDialog -Url $consentUrl -Title "Admin Consent Required" -ReturnUrl $appReplyUrl

## Show the form, and wait for the response 
if ($result -imatch "Cancel") {
    Write-Host "You must consent in order to continue."
    exit
}

Write-Host "If you successfully consented, you can now run B2BSync.ps1"
