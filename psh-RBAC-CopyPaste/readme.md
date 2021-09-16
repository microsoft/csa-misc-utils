## Overview

Azure subscriptions can be re-homed from one Azure AD tenant to another: https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-subscriptions-associated-directory#to-associate-an-existing-subscription-to-your-azure-ad-directory

This process removes all Role-Based Access Control (RBAC) assignments. These scripts are designed to back-up those RBAC assignments, 
and document existing service principals and users. They then create new service principals with the same names in the destination 
tenant, and document the new IDs. Finally, they retrieve the list of users and service principals from the destination tenant, then 
crosswalk them against the source principals and update the RBAC assignment data from the source with the destination principal IDs.
Finally, they re-apply the RBAC permissions in the destination tenant.

This script is a proof of concept and does not attempt to address every edge case. For example, the service principals that are created
in the destination do not pick up any API permission assignments. 

__PLEASE REVIEW, TEST, VALIDATE, AND ENHANCE AS NECESSARY BEFORE RUNNING AGAINST ANYTHING IN PRODUCTION.__

## Steps

__Step 1:__

* Update settings.json with your subscription, source and destination environment information
* Run ExtractRBAC.ps1 (login with a GA account in the source tenant)
* Run CreateDestSPs.ps1 (login with a GA account in the dest tenant)
    IMPORTANT: new SP secret(s) are generated and placed in the "NewServicePrincipals.json" file
* Ensure that on-prem AD sync has been redirected from the source tenant to the destination tenant

__Step 2:__

* Re-parent the subscription from the source tenant to the destination tenant
* Wait until the subscription is confirmed as visible under the destination tenant (~10 minutes)

__Step 3:__

* Ensure that the user executing the ApplyRBAC script has logged in and enabled Access Management for Azure Resources under AAD
* Run ApplyRBAC.ps1 (login with a GA account in the dest tenant)

## Notes

* When remapping RBAC from a source tenant to a destination tenant for a subscription, the script checks for matching ImmutableId or mail attributes
https://github.com/Microsoft/csa-misc-utils/blob/master/psh-RBAC-CopyPaste/ApplyRBAC.ps1#L30. Make sure you test and validate that these matching rules 
will work for your scenario. Two possible areas to consider are (1) B2B guests that exist in both tenants, and (2) on-prem identities that were 
previously syncing to the source tenant, but will be moved (along with their validated domain names) to sync to the destination tenant.
* Consider creating Management Group root roles in the destination tenant so admins can immediately gain access 
in the new directory.
* For managed service accounts: If you move a subscription to another directory, you will have to manually 
re-create them and grant Azure RBAC role assignments again.
   * For system assigned managed identities: disable and re-enable.
   * For user assigned managed identities: delete, re-create and attach them again to the necessary resources (e.g. virtual machines)
* If you get an error on line 77 (assigning the roles) when running ApplyRBAC.ps1, be sure that the login includes your access to the subscription, 
now in the destination tenant. You can verify this by inspecting the $ctx variable after line 7 to verify that the Subscription column is populated.
