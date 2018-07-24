A guest, with "Guest Inviter" privileges, may invite other users from her home tenant to the guest tenant.
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
