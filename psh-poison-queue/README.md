Azure Storage Queue will move a failed queue entry to the poison queue after a set number of failures. 
Once the failure is corrected, it may be useful to move the items from the poison queue back into the main queue.
This PowerShell script uses the Azure Storage SDK to make this easy - useful while developing a solution.