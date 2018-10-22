#CREDS
# objectIds
$SourceTenantId = "[Replace with tenantid of source tenant 2]"
$SourceGroupId  = "[Replace with groupid of members to be synced from source tenant 2]"
$DestTenantId   = "[Replace with tenantid of destination tenant 1]"
$DestGroupId    = "[Replace with groupid of members that have been synced from source tenant 2 to this dest tenant]"

# Create in Destination tenant - requires Azure AD configuration (refer to docs)
$appID          = "[appid that will be facilitating all of this - see readme]"
$appSecret      = "[secret for that appid]"
$appReplyUrl    = "[reply URL for that appid]"

#if guest user is removed from the source group, also remove guest user from dest tenant?
$RemoveGuest = $false

$CustomOIDAttributeName = "CustomOID"