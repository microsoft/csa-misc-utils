<#
A guest, with "Guest Inviter" privileges, may invite other users from her home tenant to the guest tenant
    https://docs.microsoft.com/en-us/azure/active-directory/b2b/delegate-invitations
    https://docs.microsoft.com/en-us/azure/active-directory/b2b/add-user-without-invite
    https://docs.microsoft.com/en-us/azure/active-directory/active-directory-b2b-redemption-experience

    The scenario here is a newly acquired company, Fabrikam, has it's own AAD tenant. Contoso, the new 
    parent company, wants to add a number of Contoso users as guests in the Fabrikam tenant. A Contoso admin
    is added as a guest in Fabrikam, then that admin is granted the "Guest Inviter" role in Fabrikam. The
    admin then runs this script, authenticates to Contoso, then sets the focus to Fabrikam (guest tenant id), and
    invites an array of Contoso users to Fabrikam. Since the admin is inviting users from his own tenant into 
    the tenant where he's a guest, those users are automatically added. As the new guests don't need to
    consent to the invitation, no invitation email will be sent.
#>

$guestTenantId = "[acquired company tenant, eg fabrikam.com]"

#sign in using your home (HQ, acquiring company, like Contoso) credentials, but focused on the tenant where you're a guest
Connect-AzureAD -TenantId $guestTenantId

#list of users from your home tenant that you want to be automatically invited to this tenant
$userList = @("bob@contoso.com","mary@contoso.com","jane@contoso.onmicrosoft.com")

#optional - load list of users from a CSV file
#$userList = (get-content "c:\temp\userlist.csv").Split(',')

#spin through these users and send each an invitation
ForEach($user in $userList) {
    AzureAD\New-AzureADMSInvitation -InvitedUserEmailAddress $user -SendInvitationMessage $false -InviteRedirectUrl "https://myapps.microsoft.com/$guestTenantId"
}
