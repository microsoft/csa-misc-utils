# Deploying a Kubernetes Cluster in Azure
<br>Getting to this folder means you started with the setup and keyVault folders. In order to deploy this cluster, you need a service principal in AAD and a public SSH key. Between the setup and keyVault folder, you should have generated a service principal, generated a public SSH key, created a Key Vault, and stored both of those secrets to reference within the template. 

**Information on K8s Configuration**
<br><br>Within this folder, you will find the following files:

1) **aksDeploy.json** - ARM template that deploys the Kubernetes cluster. This file declares all the Kubernetes cluster, which comprises of deploying nodes (VMs), nics, the Availability Set, and the NSG. Additional comments:
<i><br>- This deployment deploys a private load balancer as an nginx ingress controller.
 <br>- This deployment reports to an existing Log Analytics workspace.</i>
  
2) **aksParams.json** - this is the parameters file for the ARM template deployment. Future deployments can be conducted by editing these parameters first and then re-deploying.

3) **kubectl-helm-commands.md** - this file guides you on how to connect to your Kubernetes cluster, create a namespace, create a Tiller service account for helm, install helm, and create an internal ingress controller for your Kubernetes cluster. 

4) **helm-rbac.yaml** - this is the file to run while connected to your Kubernetes cluster so you can create the Tiller service account for helm.

5) **ingress-internal.yaml** - this is the file to use for your larger helm command to install an nginx internal ingress controller. 

