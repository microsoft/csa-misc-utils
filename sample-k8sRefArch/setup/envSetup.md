## Configure Environment (either local or in Azure using Cloud Shell)
<br>
<b>Requirements:</b>
<br>1. Azure CLI OR
<br>2. Az PowerShell Module
<br>3. Cloud Shell - If you cannot install the Azure CLI or Az PowerShell Module locally, Cloud Shell is another alternative for running commands, scripts, and templates.
<br>4. Windows Subsystem for Linux
<br><br><i>Links:</i>
<br>Bash/AzureCLI - https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart
<br>PowerShell - https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart-powershell
<br>Install Windows Subsystem for Linux - https://docs.microsoft.com/en-us/windows/wsl/install-win10
<br><br>
<b>Login to your Azure account:</b>

    az login
Note: Cloud Shell automatically logs you in your account.

AKS needs permissions to manage resources in Azure & interact with Azure APIs e.g. launching LoadBalancers, virtual machines etc. Assuming that you have required permissions to create Service Principal, let's create a managed cluster. \
The RBAC role needs minimal permission of "Network Contributer" role on the subnet it'll launch nodes, podes and services and of "Reader" role to pull images from ACR.

**Create Service Principal (SP):**

    az ad sp create-for-rbac -n <NameOfServicePrincipal> --skip-assignment


>You should get output similar to shown below:

    {
    "appId": "13abc4e6-2w2w-9i8u-3856-645127d63bfc",
    "displayName": "NameOfServicePrincipal",
    "name": "http://NameOfServicePrincipal",
    "password": "038855b8-35vb-44c1-1010-a3543519e9a3",
    "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
    }

>appID is your clientID \
password is your password for SP (obviously) \
and finally you need objectID

**Find Object ID of the SP created above:**

    az ad sp show --id "<appID>"

>Scroll down to the bottom of the output of above command & you'll see objectID similar to this:

    "objectId": "715d88c2-58a0-4f88-8246-7f1a304c5bed"

>Note them down as these values are needed for deploying AKS cluster.

**Install Azure PowerShell module if it's not already installed & connect to your account - not needed if using Azure Cloud Shell**

    Install-Module -Name Az -AllowClobber
    Connect-AzAccount

**Setup deployment variables:**\
PowerShell:

    $location = 'eastus'
    $resourceGroupName = 'demok8srg'

Bash:

    location='eastus'
    resourceGroupName='demok8srg'

    # Persistence for later sessions in case of timeout - for cloud shell only
    echo location=$location >> ~/.bashrc
    echo resourceGroupName=$resourceGroupName >> ~/.bashrc


**Create resource group to place all deployed resources together:**\
PowerShell:

    New-AzResourceGroup `
     -Name $resourceGroupName `
     -Location $location `
     -Verbose -Force

Bash:

    az group create --name $resourceGroupName --location $location

**Kubernetes and Helm CLI Installation:**
<br>In order to run the Kubernetes and Helm commands, you will need to install both (either locally or via Cloud Shell). Please examine these instructions and pick the best setup for your environment:
<br><br>1. Kubernetes -  https://kubernetes.io/docs/tasks/tools/install-kubectl/
<br>2. Helm (just install Helm, don't initialize) - https://github.com/helm/helm/blob/master/docs/install.md
