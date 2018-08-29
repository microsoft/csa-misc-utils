## Sending Encrypted Mail From a Script

Eventually, you're going to want to send an email from a script. This is really straightforward using Exchange Online and the Microsoft Graph API. But what if you want those emails to be encrypted? Sometimes, log information may be put in an email, and there may be something sensitive in that log.

Azure Information Protection enables encryption, and it's also easy. But how to activate it from a script? There’s no apparent way to specify encryption in the Graph call, but you CAN setup default rules as an Exchange admin, that apply to a given user account. So the API call is over TLS, and once it gets to EXO through Graph, EXO will encrypt it before storing it or sending it.

There are two approaches to accomplishing this:

1.	In both cases:
     
    a.	create a new user account and assign it a mailbox in EXO (limit its permissions all you want, as long as it can send email)
    
    b.	Create an app registration. Get the AppID and create an app secret
    
2.	Case A – Sending on behalf of this user
    
    a.  Assign it Application permissions to the Microsoft Graph API, allowing it to send email impersonating anyone in the org (this requires GA approval)

    b.	The script authenticates as the application, using the client_credential grant type. It calls https://graph.microsoft.com/v1.0/users/{0}/sendMail, filling in the UPN of the sending account mailbox.
3.	Case B – Sending AS the user
    
    a.  Assign it delegated permissions to the Microsoft Graph API, allowing it to send on behalf of the logged-in user (doesn’t require admin approval)

    b.	The script authenticates as the user, using the password grant type. It calls https://graph.microsoft.com/v1.0/me/sendMail

Here’s the REST reference:
https://developer.microsoft.com/en-us/graph/docs/api-reference/v1.0/api/user_sendmail

Here’s the EXO mail flow encryption doc:
https://docs.microsoft.com/en-us/office365/securitycompliance/define-mail-flow-rules-to-encrypt-email
