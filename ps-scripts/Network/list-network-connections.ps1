<#
.SYNOPSIS
	Lists network connections
.DESCRIPTION
	This PowerShell script lists all active network connections on the local computer.
.EXAMPLE
	PS> ./list-network-connections.ps1
.CATEGORY Network
#>

#Requires -Version 5.1

try {
	& netstat -n
	exit 0
} catch {
throw
}
