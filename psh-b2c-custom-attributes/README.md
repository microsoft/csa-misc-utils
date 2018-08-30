## Work With B2C Custom Attributes via REST

When you create a custom attribute in Azure AD B2C, like "ShoeSize", it gets saved with a funky long name. This script includes
a REST call that will retrieve the collection of custom attributes and store them in memory, then refer to that list to 
create the correct REST url for updating that attribute.

You'll need to have your access token populated in $token, and put your tenant name in $Tenant. There are sample calls commented at the bottom of the file.

NOTE: This is using the Azure AD Graph API.
<hr>
Here’s the REST reference:
https://msdn.microsoft.com/en-us/library/azure/ad/graph/api/functions-and-actions#getAvailableExtensionProperties

