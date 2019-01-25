import logging
import azure.functions as func

from azure.keyvault import KeyVaultClient, KeyVaultAuthentication
from azure.common.credentials import ServicePrincipalCredentials
# see https://docs.microsoft.com/en-us/python/api/overview/azure/key-vault?view=azure-python

def auth_callback(server, resource, scope):
    credentials = ServicePrincipalCredentials(
        client_id = '<CLIENT ID>',
        secret = '<CLIENT SECRET>', 
        tenant = '<TENANT GUID>',
        resource = "https://vault.azure.net"
    )
    token = credentials.token
    return token['token_type'], token['access_token']

client = KeyVaultClient(KeyVaultAuthentication(auth_callback))

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    secret_bundle = client.get_secret("https://<YOUR VAULT NAME>.vault.azure.net/", "<SECRET NAME>", "<SECRET VERSION>")
    return func.HttpResponse(f"{secret_bundle.value}!")