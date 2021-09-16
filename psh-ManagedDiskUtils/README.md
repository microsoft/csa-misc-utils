# Azure Managed Disk and Image PowerShell Utilities

This is a collection of various managed disk PowerShell scripts to perform actions in an automated manner.

* [Copy Managed Image to Another Region](./CopyDiskImage_verified.ps1).
Managed images in Azure have no direct facilities to access the underlying URL/path the disk resides in since they are placed into storage accounts under the hood by Azure.  Often times there's a desire to take a generalized VM (image) from one region and move to another region. This script provides a mechanism to do this - UPDATE! Azure now has a native means to do this via a feature called [Shared Image Gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/shared-image-galleries).  The benefit of this feature is that Microsoft will copy the images to your target regions automatically allowing you to build a 'private' marketplace of sorts

* [Copy Managed Disk to Another Region](./ManagedDiskCopy.ps1).
Managed disks in Azure have no direct facilities to access the underlying URL/path the disk resides in since they are placed into storage accounts under the hood by Azure.  Often times there's a desire to take a managed disk attached to a VM from one region and move to another region where you can create a NEW VM and attach the copied disk effectively cloning the VM int the destination region. This script provides a mechanism to do this outside of native features in Azure that allow you to move resources from one region to another (requiring the entire virtual network and related VMs be moved as well) or using the Azure Site Recovery feature to replicate to another region and fail-over.  This is a simple means to copy raw disks to a destination region of your choice.

* [Remove Orphaned VHDs](./RemoveOrphanedDisks.ps1).
Managed disks linger when the source VM is removed in the event you wish to attach them to another VM. This PowerShell script will walk through storage accounts in the subscription specified or the susbcription(s) you have access to locating any disks that are not attached to a VM
