## Azure ARM Samples -- VMSS with a domain join

I was recently working with a customer who needed to create VMs on-demand that were domain joined to complete HPC compute operations.  This is an example template highlighting how to create VM Scale Set instances from a template pointing to a 'golden image' as a source and domain joining each VM spun up.

Note: The source image must reside in the same region as the VM Scale Sets for this to function.  The source image can reside in a different resource group; as there are parameters for both the source image and resource group as well as the name of an existing Virtual Network and subnet to deploy each instance into.


* [VMSS Example](./WindowsVirtualMachineScaleSet_DomainJoin.json).
The example ARM template

