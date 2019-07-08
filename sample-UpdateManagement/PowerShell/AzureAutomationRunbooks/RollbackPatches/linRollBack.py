#
# Created 
# 2019.02.27
# Shannon Kuehn
# Last Updated
#
# © 2019 Microsoft Corporation. 
# All rights reserved. Sample scripts/code provided herein are not supported under any Microsoft standard support program 
# or service. The sample scripts/code are provided AS IS without warranty of any kind. Microsoft disclaims all implied 
# warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event 
# shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for 
# any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of 
# business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or 
# documentation, even if Microsoft has been advised of the possibility of such damages.


import os
from azure.mgmt.compute import ComputeManagementClient
import azure.mgmt.resource
import automationassets

def get_automation_runas_credential(runas_connection):
    from OpenSSL import crypto
    import binascii
    from msrestazure import azure_active_directory
    import adal

    # Get the Azure Automation RunAs service principal certificate
    cert = automationassets.get_automation_certificate("AzureRunAsCertificate")
    pks12_cert = crypto.load_pkcs12(cert)
    pem_pkey = crypto.dump_privatekey(crypto.FILETYPE_PEM,pks12_cert.get_privatekey())

    # Get run as connection information for the Azure Automation service principal
    application_id = runas_connection["ApplicationId"]
    thumbprint = runas_connection["CertificateThumbprint"]
    tenant_id = runas_connection["TenantId"]

    # Authenticate with service principal certificate
    resource ="https://management.core.windows.net/"
    authority_url = ("https://login.microsoftonline.com/"+tenant_id)
    context = adal.AuthenticationContext(authority_url)
    return azure_active_directory.AdalAuthentication(
    lambda: context.acquire_token_with_client_certificate(
            resource,
            application_id,
            pem_pkey,
            thumbprint)
    )

# Authenticate to Azure using the Azure Automation RunAs service principal
runas_connection = automationassets.get_automation_connection("AzureRunAsConnection")
azure_credential = get_automation_runas_credential(runas_connection)

# Initialize the compute management client with the RunAs credential and specify the subscription to work against.
compute_client = ComputeManagementClient(
azure_credential,
  str(runas_connection["SubscriptionId"])
)

list_of_servers = ["host1", "host2", "host3", "host4", "host5"]

for server in list_of_servers:
  subprocess.call(['yum remove package_name'], shell=True)
