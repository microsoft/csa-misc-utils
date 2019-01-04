## Azure Managed Disk and Image PowerShell Utilities

This is a collection of various managed disk PowerShell scripts to perform actions in an automated manner.


* [Copy Managed Disk to Another Region](./CopyDiskImage_verified.ps1).
Managed disks in Azure have no direct facilitites to access the underlying URL/path the disk resides in since they are placed into storage accounts under the hood by Azure.  Often times there's a desire to take a generalized VM from one VM and move to another region. This script provides a mechanism to do this.

* [Remove Orphaned VHDs](./RemoveOrphanedDisks.ps1).
Managed disks linger when the source VM is removed in the event you wish to attach them to another VM. This PowerShell script will walk through storage accounts in the subscription specified or the susbcription(s) you have access to locating any disks that are not attached to a VM