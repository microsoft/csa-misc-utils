<b>Kusto Queries - Detailed Explanations:</b> 
1) CVE Numbers are only listed for Linux within the underlying database engine for Kusto, except not every Linux server 
patch contains a CVE Number. 
2) For the pre and post analysis queries, TimeGenerated refers to when the patch applies. In order to ensure you grab 
data for the past month, the TimeGenerated needs to be in the initial part of the Kusto query.
