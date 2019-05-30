<h3>List of Azure Services that require a dedicated subnet</h3>
The following services can be deployed on a VNet but require a Subnet that cannot have any other Azure resource consiming the subnet private IPs. The minimum size for a Subnet in Azure is /29 whih provides 8 IP Addresses. However, Azure reserves some IP addresses within each subnet. The first and last IP addresses of each subnet are reserved for protocol conformance, along with the x.x.x.1-x.x.x.3 addresses of each subnet, which are used for Azure services.<br/><br/>
<table>
<tr>
<th>Service</th>
<th>Subnet Size</th>
<th>Documentation</th>
</tr>
<tr>
<td>VPN and ExpressRoute Gateways</td>
<td>/27</td>
<td>https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-vpn-faq
https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-add-gateway-portal-resource-manager</td>
</tr>
<tr>
<td>App Gateway</td>
<td>/28</td>
<td>This size gives you 11 usable IP addresses. If your application load requires more than 10 IP addresses, consider a /27 or /26 subnet size.
https://docs.microsoft.com/en-us/azure/application-gateway/configuration-overview#size-of-the-subnet</td>
</tr>
<tr>
<td>Azure Firewall</td>
<td>/26</td>
<td>https://docs.microsoft.com/en-us/azure/firewall/tutorial-firewall-deploy-portal
</td>
</tr>
<tr>
<td>App Service Environment</td>
<td>/24</td>
<td>https://docs.microsoft.com/en-us/azure/app-service/environment/network-info</td>
</tr>
<tr>
<td>Redis Cache</td>
<td>/27</td>
<td>Each Redis instance in the subnet uses two IP addresses per shard and one additional IP address for the load balancer. A non-clustered cache is considered to have one shard.
https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-premium-vnet
</td>
</tr>
<tr>
<td>API Management</td>
<td>/27</td>
<td>https://docs.microsoft.com/en-us/azure/api-management/api-management-faq</td>
</tr>
<tr>
<td>SQL Server Managed Instance
</td>
<td>/27</td>
<td>https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance-connectivity-architecture#network-requirements
</td>
</tr>
<tr>
<td>Integration Service Environment</td>
<td>/27</td>
<td>https://docs.microsoft.com/en-us/azure/logic-apps/connect-virtual-network-vnet-isolated-environment#create-subnet</td>
</tr>
</table>
