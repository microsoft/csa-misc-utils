<i>Created 
<br>2019.07.05
<br>Shannon Kuehn
<br><br>
© 2019 Microsoft Corporation. 
<br>All rights reserved. Sample scripts/code provided herein are not supported under any Microsoft standard support program 
or service. The sample scripts/code are provided AS IS without warranty of any kind. Microsoft disclaims all implied 
warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event 
shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for 
any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of 
business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or 
documentation, even if Microsoft has been advised of the possibility of such damages.</i>

# Infrastructure as Code
Reference Architecture
<br><i>Azure Kubernetes Service (AKS) - Azure CNI Plugin</i>
<br><br>Files/Folders for this Repository:
<br>   1) **README.md** - markdown file that contains all information for repo (files, folders, steps).
<br>   2) **setup folder** - general setup information (Azure CLI, PowerShell, generating ssh keys, setting up Service Principal)
<br>   3) **keyVault folder** - code to set up a Key Vault for public SSH keys, Service Principal secret, and SSL cert password.
<br>   4) **k8s folder** - base template and yaml files for secure, managed K8s cluster on Azure. 
<br>   5) **appGw folder** - takes the k8s configuration files and adds an Application Gateway.
<br>   6) **apim-appGw folder** - takes the k8s configuration files and adds an API Management Gateway + Application Gateway.
