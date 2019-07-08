## kubectl and helm commands


<b>Connect and Configure Internal Ingress Controller for K8s:</b>

    az aks get-credentials --name k8sSecure --resource-group k8sSecure
    Merged "k8sSecure" as current context in /Users/username/.kube/config
    
    kubectl apply -f ingress-internal-l.yaml
    kubectl get service secure-k8s
    
    NAME           TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
    internal-app   LoadBalancer   10.0.248.59   10.10.1.200    80:30555/TCP   2m

<b>Create namespace internal-ingress</b>
    
    kubectl create namespace internal-ingress
    
<b>Install Helm Locally or via Cloud Shell (then use helm-rbac.yaml file from repo for next step)</b>
        
    kubectl apply -f helm-rbac.yaml
    helm init \
    --service-account tiller \
    --node-selectors "beta.kubernetes.io/os"="linux"

<b>Use Helm to Deploy a NGINX Ingress Controller (use ingress-internal.yaml file in repo)</b>
    
    helm install stable/nginx-ingress \
    --namespace internal-ingress \
    -f ingress-internal.yaml \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
    
    kubectl get service -l app=nginx-ingress --namespace internal-ingress
    
    NAME                                            TYPE         CLUSTER-IP     EXTERNAL-IP PORTS                       AGE
    alternating-coral-nginx-ingress-controller      LoadBalancer 10.0.248.59    10.10.1.200 80:31507/TCP,443:30707/TCP  1m
    alternating-coral-nginx-ingress-default-backend ClusterIP    10.0.134.66    <none>      80/TCP                      1m
    
