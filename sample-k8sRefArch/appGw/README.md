# Application Gateway
<br>Getting to this folder means you started with the setup, keyVault, and k8s folders. By the point you reach this folder, you should have a public SSH key stored in Key Vault, a Service Principal with secret stored in Key Vault, a VNet, and a K8s cluster with an internal ingress controller. In the event you do not have that set up, please ensure you start with the setup and keyVault folders. The files K8s within this folder will also generate the same AKS setup so you can add an Application Gateway. The difference between this folder and the k8s folder is you will create an echo api service on your cluster.

**Deployment Notes**
<br><br>There are a few additional files in this folder:
<br>1) **echo-api.yaml** - once the K8s cluster is deployed, apply this yaml file to the K8s cluster by running kubectl apply -f echo-api.yaml (as is, no adjustments). The yaml file has already been adjusted from an internal ingress GitHub sample repo, located <a href="https://github.com/kubernetes/ingress-nginx/blob/master/docs/examples/customization/external-auth-headers/deploy/echo-service.yaml">here</a>. The major tweaks to this yaml file are related to removing the auth headers from the original. Deploying the echo service allows the Application Gateway to use a custom probe for backend health reporting.
<br>2) **appGwDeploy.json** - this is the ARM template that adds an Application Gateway to the final deployment. The SSL cert password needs to be passed as a string vs. a secure string. There is a custom probe that leans on an echo service you deploy prior to deploying the Application Gateway.
<br>3) **appGwParams.json** - this is the parameters file for the ARM template deployment. 
<br><br>Deploying all 3 files will add an Application Gateway to your existing internal K8s cluster. The Application Gateway will have a public IP address, have WAF enabled, and WAF rules are configured for deployment. All configurations can be adjusted to fit your deployment requirements.

**Information on K8s Configuration**
<br><br>Within this folder, you will find the following files:

1) **aksDeploy.json** - ARM template that deploys the Kubernetes cluster. This file declares all the Kubernetes cluster, which comprises of deploying nodes (VMs), nics, the Availability Set, and the NSG. Additional comments:
<i><br>- This deployment does not deploy a public load balancer.
 <br>- This deployment reports to an existing Log Analytics workspace.</i>
  
2) **aksParams.json** - this is the parameters file for the ARM template deployment. Future deployments can be conducted by editing these parameters first adn re-deploying.

3) **kubectl-helm-commands.md** - this file guides you on how to connect to your Kubernetes cluster, create a namespace, create a Tiller service account for helm, install helm, and create an internal ingress controller for your Kubernetes cluster. 

4) **helm-rbac.yaml** - this is the file to run while connected to your Kubernetes cluster so you can create the Tiller service account for helm.

5) **ingress-internal.yaml** - this is the file to use for your larger helm command to install an nginx internal ingress controller. 

