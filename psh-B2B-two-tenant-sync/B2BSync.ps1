<#
See README.txt for details
#IMPORTANT: edit "B2BSync-MyVars.ps1 and fill in your variables - see README

*** Recommended ToDo/caveats for production deployments
    - add certificate based authentication for Service Principal Name
    - add reporting - should be off by default but available for troubleshooting
#>

# Set up variables
# Dot-sourcing variables - update "B2BSync-Myvars.ps1 and use that file name
. "$PSScriptRoot\B2BSync-MyVars.ps1"
. "$PSScriptRoot\B2BSync_CustomAttributes.ps1"

# No need to modify more variables

# Variable initialization
$SourceTokenAADGraph   = $null
$SourceTokenMSGraph    = $null
$DestTokenAADGraph     = $null
$DestTokenMSGraph      = $null
$SourceGroupUsersHash  = @{} 
$DestGuestUsersHash    = @{}
$DestGroupUsersHash    = @{} 
$loginURL              = "https://login.microsoftonline.com/" # AAD Instance; for example https://login.microsoftonline.com for public or https://login.microsoftonline.us for government cloud

function Auth-Tenant() {
    Param(
         [Parameter(Mandatory=$true, Position=0, HelpMessage="Select target tenant")]
         [ValidateSet('Source','Dest')]
         [String]$Tenant,
         [Parameter(Mandatory=$false, Position=1, HelpMessage="Select target resource")]
         [ValidateSet('MSGraph','AADGraph')]
         [String]$ResourceType = 'AADGraph'
    )
    $AADGraph = "https://graph.windows.net"
    $MSGraph = "https://graph.microsoft.com"

    $resource = Invoke-Expression "`$$($ResourceType)"

    $body = @{grant_type="client_credentials";resource=$resource;client_id=$appID;client_secret=$appSecret}

    $tenantId = Invoke-Expression "`$$($Tenant)TenantId"
    $oauth = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantId/oauth2/token?api-version=1.5 -Body $body
    $token = $oauth.access_token
    $exp = "`$Global:" + $Tenant + "Token" + $ResourceType + " = '" + $token + "'"
    Invoke-Expression $exp
    $ctx = Connect-AzureAD -AadAccessToken $oauth.access_token -TenantId $tenantId -AccountId $appID

    Write-Host "Connected to $Tenant"
}

function Set-Tenant() {
    Param(
         [Parameter(Mandatory=$true, Position=0, HelpMessage="Select target tenant")]
         [ValidateSet('Source','Dest')]
         [String]$Tenant,
         [Parameter(Mandatory=$false, Position=1, HelpMessage="Select target resource")]
         [ValidateSet('MSGraph','AADGraph')]
         [String]$ResourceType = 'AADGraph'
    )
    $exp = "`$currToken = `$Global:" + $Tenant + "Token" + $ResourceType
    Invoke-Expression $exp
    $ctx = Connect-AzureAD -AadAccessToken $oauth.access_token -TenantId $tenantId -AccountId $appID
}

function Load-SourceGroupMembers() {
    # Populate hash table with membership of source group from Azure AD using object ID as key
    # we will then reference across into the Guest use hash table as needed.

    Get-AzureADGroupMember -ErrorAction Stop -ObjectId $SourceGroupId -all $true | `
	    ForEach-Object {$SourceGroupUsersHash[$_.ObjectId] = $_}
    Write-Host "Loaded source group members"
}

function Load-DestGuests() {
    # Populate hash table with all Guest users from dest tenant using object ID as key

    Get-AzureADUser -ErrorAction Stop -All $true -Filter "userType eq 'Guest'" |  `
	    ForEach-Object {$DestGuestUsersHash[$_.ObjectId] = $_}
    Write-Host "Loaded destination guests"
}

function Load-DestGroupMembers() {
    # Populate hash table with membership of source group from Azure AD using object ID as key
    # we will then reference across into the Guest use hash table as needed.

    Get-AzureADGroupMember -ErrorAction Stop -ObjectId $DestGroupId -all $true | `
	    ForEach-Object {$DestGroupUsersHash[$_.ObjectId] = $_}
    Write-Host "Loaded destination group members"
}

function Sync-Users() {
    $CustAttrFullName = (Get-Attr -Attribute $CustomOIDAttributeName).name

    #adding users in destination
    ForEach($key in $($SourceGroupUsersHash.Keys)) {

        $user = $SourceGroupUsersHash[$Key]
        $userGuestId = $user.ExtensionProperty.Item($CustAttrFullName)

        $destUser = $DestGuestUsersHash.Values | where { $_.ObjectId -eq $userGuestId }
        if($destUser -eq $null) {
            #source group member isn't a B2B guest - invite
            
            $mail = if($user.Mail -eq $null) { $user.UserPrincipalName } else { $user.Mail }
            
            $newUser = Send-B2BInviteGraph `
                            -Email $mail `
                            -RedirectTo "https://myapps.microsoft.com/$DestTenantId" `
                            -UserType Guest `
                            -GraphToken $global:DestTokenMSGraph `
                            -DisplayName ($user.DisplayName + " (guest)") `
                            -ErrorAction Stop `
                            -ErrorVariable inviterr

            if ($inviteerr -ne $null) {
                exit
            }

            $newUserId = $newUser.invitedUser.id

            #Add remote userID to local account so we can track when they're removed
            Set-CustomUserAttr -UserOID $user.ObjectId -Attribute $CustomOIDAttributeName -Value $newUserId

            #Since they weren't in the tenant, they weren't in the group - add them
            AzureAD\Add-AzureADGroupMember -ObjectId $DestGroupId -RefObjectId $newUserId
        }
        else {
            $destUser2 = $DestGroupUsersHash.Values | where { $_.ObjectId -eq $userGuestId }

            if ($destUser2 -eq $null) {
                #user was already a guest but not in the group - add them
                AzureAD\Add-AzureADGroupMember -ErrorAction Stop -ObjectId $DestGroupId -RefObjectId $destuser.objectId
            }
        }
    }

    #removing users from destination
    ForEach($key in $($DestGroupUsersHash.Keys)) {

        $destUser = $DestGroupUsersHash[$Key]
        #see if that user is missing from local group

        $userGuestId = $user.ExtensionProperty.Item($CustAttrFullName)

        $SourceUser = $SourceGroupUsersHash.Values | where { $_.ExtensionProperty.Item($CustAttrFullName) -eq $destUser.ObjectId }

        if($SourceUser -eq $null) {
            #user is there but no longer here - remove them
            if ($RemoveGuest) {
                #remove guest account from destination
                AzureAD\Remove-AzureADUser -ObjectId $destUser.objectId
            } else {
                #remove from group only
                AzureAD\Remove-AzureADGroupMember -ObjectId $DestGroupId -MemberId $destUser.objectId
            }

        }
    }
}

#https://developer.microsoft.com/en-us/graph/docs/api-reference/v1.0/api/invitation_post
function Send-B2BInviteGraph {
    param (
        [Parameter( Position = 0, Mandatory = $true)]
        [string]$Email,

        [Parameter( Position = 1, Mandatory = $true)]
        [string]$DisplayName,

        [Parameter( Position = 2, Mandatory = $true)]
        [string]$RedirectTo,

        [Parameter( Position = 3, Mandatory = $true)]
        [ValidateSet('Guest','Member')]
        [string]$UserType,

        [Parameter( Position = 4, Mandatory = $true)]
        [string]$GraphToken
    )

    $endPoint = "https://graph.microsoft.com/v1.0/invitations"
    $Headers = @{Authorization = "Bearer "+$GraphToken}

    $invitation = @{
        InvitedUserDisplayName = $DisplayName;
        InvitedUserEmailAddress = $Email;
        InviteRedirectUrl = $RedirectTo;
        SendInvitationMessage = $true;
        InvitedUserType = $UserType;
    }
    $Body = ConvertTo-Json $invitation

    $res = Invoke-WebRequest -Uri $endPoint -Method Post -Headers $Headers -Body $Body -ErrorAction Stop
    return ConvertFrom-Json $res.Content
}

Auth-Tenant -Tenant Source -ResourceType AADGraph
Load-SourceGroupMembers

Auth-Tenant -Tenant Dest -ResourceType MSGraph
Sleep -Seconds 2
Auth-Tenant -Tenant Dest -ResourceType AADGraph
Sleep -Seconds 2

Load-DestGuests
Load-DestGroupMembers

Sync-Users