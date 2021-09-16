import logging
import azure.functions as func
from azure.keyvault import KeyVaultClient
from msrestazure.azure_active_directory import MSIAuthentication, ServicePrincipalCredentials

credentials = MSIAuthentication(
    resource='https://vault.azure.net'
)
client = KeyVaultClient(
    credentials
)

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    secret_bundle = client.get_secret("https://<YOUR VAULT NAME>.vault.azure.net/", "<SECRET NAME>", "<SECRET VERSION>")
    return func.HttpResponse(f"{secret_bundle.value}!")