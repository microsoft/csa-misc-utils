# Application Gateway and API Management Gateway
<br>Getting to this folder means you started with the setup, keyVault, and k8s folders. By the point you reach this folder, you should have a public SSH key stored in Key Vault, a Service Principal with it's secret stored in Key Vault, a VNet, and a K8s cluster with an internal ingress controller. In the event you do not have that set up, please ensure you start with the setup and keyVault folders. The K8s template and yaml files within this folder will also generate the same AKS setup so you can add an API Management Gateway and Application Gateway. The API Management Gateway will publish a health check API that serves as an echo service to itself so the Application Gateway backend health can report as "healthy."

**Deployment Notes**
<br><br>There are a few additional files in this folder:
<br>1) **appGwApimDeploy.json** - this is the deployment ARM template for both the Application Gateway and the API Management Gateway. The APIM is set as internal and the healthcheck API code is configured as an API, an API operation, and an API policy. The end configuration has a custom healthcheck API exposed on the APIM that allows the Application Gateway's backends to report as healthy.
<br>2) **appGwApimParams.json** - these are the parameters for the Application Gateway and APIM deployment.

**Information on K8s Configuration**
<br><br>Within this folder, you will find the following files:

1) **aksDeploy.json** - ARM template that deploys the Kubernetes cluster. This file declares all the Kubernetes cluster, which comprises of deploying nodes (VMs), nics, the Availability Set, and the NSG. Additional comments:
<i><br>- This deployment does not deploy a public load balancer.
 <br>- This deployment reports to an existing Log Analytics workspace.</i>
  
2) **aksParams.json** - this is the parameters file for the ARM template deployment. Future deployments can be conducted by editing these parameters first adn re-deploying.

3) **kubectl-helm-commands.md** - this file guides you on how to connect to your Kubernetes cluster, create a namespace, create a Tiller service account for helm, install helm, and create an internal ingress controller for your Kubernetes cluster. 

4) **helm-rbac.yaml** - this is the file to run while connected to your Kubernetes cluster so you can create the Tiller service account for helm.

5) **ingress-internal.yaml** - this is the file to use for your larger helm command to install an nginx internal ingress controller. 

