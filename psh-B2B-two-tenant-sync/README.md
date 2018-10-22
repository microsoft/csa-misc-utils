# Sync Azure AD B2B Guests to between tenants

## Overview

Sample script to create B2B guests in a subsidiary/remote/destination Azure AD tenant, synchronized from
users in specific group of a corp/source tenant.

and a separate list of User accounts in a specific group of a 2nd Azure AD tenant

* Will ensure Users from tenant 2 are guests in tenant 1, in the same group
* Will ensure that Users removed from the group in tenant 2 are removed as guests from tenant 1

This is used to synchronize users in a "source" corp tenant (tenant 2) as B2B guests in a 
separate "destination" tenant (tenant 1).

	
To enable this process, a multi-tenanted application registration will be created in tenant 2 (the destination tenant)

## Configuration

1. Create app registration in destination tenant (use "http://[tenant domain name]/groupsynctool" for the URL)
2. Set as multi-tenant in settings
3. Create a new app key
4. Record the application ID and key in the powershell settings
5. Set the following permissions:
	Microsoft Azure Active Directory
		Application Permissions:
			Invite guest users to the organization
			Read all groupsynctoolRead and write directory data
			Read and write all users' full profiles
	Microsoft Graph
		Application Permissions:
			Read and write directory data
		(Delegated "Sign in and read user profile" should be there
			by default - it's not used in this scenario)

For the "MyVars.ps1" file, you will need the following:
1. Source Tenant ID
2. Source Tenant Group ID
3. Destination Tenant ID
4. Destination Group ID

5. App ID (from above)
6. App Secret (from above)
7. App reply URL (from above)

8. "RemoveUser" - if false, users removed from the source group will be removed 
	from the destination group AND removed as a guest from the destination tenant.
	if true, the user will be removed from the destination group, but left as a guest
	in the destination tenant.
	
9. "CustomOIDAttributeName" - When a source user is invited to the destination, a use ObjectID is created in the destination.
	To facilitate synchronization, that destination objectID is saved in a custom attribute associated with the source user's account,
	in the source tenant. This variable is the name of that custom attribute.
	
## Initialization

__Destination Tenant__

Once everything above has been completed, the "B2BSync_DestSetup.ps1" script will need to be run, using an account from the DESTINATION tenant with GLOBAL ADMIN privileges. This script grants the service principal associated with the app created above, the "Guest Inviter" role in the destination tenant. Then, it establishes the custom attribute in the application, which will be used to store the remote ObjectID in the source tenant.

__Source Tenant__

Now, run "B2BSync_SourceSetup.ps1" from the SOURCE tenant also using an account with GLOBAL ADMIN privileges there. This script will start your default browser and load the admin consent script for the application created above in the destination tenant. Log in with the GA account - notice that you're consenting to the same permissions you assigned to the app earlier in the destination tenant. This consent will install (behind the scenes) a second service principal in the source tenant. The two service principals are distinct in the two tenants, but both are controlled by the credentials, and granted rights articulated, in the application definition. After you consent, the application will try to redirect you back to the application URL - which is actually a URI identifier, not a web site. Ignore the error that the web page is missing, and close the browser.

__User Staging__

Before you run sync the first time, select the user(s) that will be synced from the source to the destination tenant, and add them to the group you assigned in the variable above.

__Run Sync__

Now that all of that's done, you can run "B2BSync.ps1" for the first time. It will gather an in-memory collection of users from the source group, then it will gather an in-memory collection of B2B guests from the destination group (if any). It will then compare the two lists and add users from the source group as guests in the destination tenant, then add them to the destination group, then send the invitation email. It will then check the other direction and see if any users are in the destination group that are NOT in the source group. It will remove them from the destination group, then IF the $RemoveUser variable set above is $true, it will also remove them as guests from the destination tenant.




