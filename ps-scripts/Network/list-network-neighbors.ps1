<#
.SYNOPSIS
	Lists the (cached) network neighbors
.DESCRIPTION
	This PowerShell script lists all network neighbors of the local computer (using the ARP cache).
.EXAMPLE
	PS> ./list-network-neighbors.ps1
		IPAddress                              InterfaceAlias LinkLayerAddress           State
		---------                              -------------- ----------------           -----
		192.168.178.43                         Ethernet       2C-F0-5D-E7-8E-EE      Reachable
.CATEGORY Network
#>

#Requires -Version 5.1

try {
	if ($IsLinux) {
		& ip neigh | grep REACHABLE
	} elseif ($IsMacOS) {
		& ip neigh | grep REACHABLE
	} else {
		Get-NetNeighbor -includeAllCompartments -state Permanent,Reachable | Format-Table -property @{e='IPAddress';width=38},@{e='InterfaceAlias';width=14},@{e='LinkLayerAddress';width=19},@{e='State';width=12} 
	}
	exit 0
} catch {
throw
}
