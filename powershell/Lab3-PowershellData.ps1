$adapters = get-ciminstance win32_networkadapterconfiguration 
$adapters | Where-Object ipenabled -EQ 1 | 
Select-Object Description, Index, IPAddress, IPSubnet, DNSDomain, @{n="DNSServer";e={$_.DNSServerSearchOrder }} |
Format-Table