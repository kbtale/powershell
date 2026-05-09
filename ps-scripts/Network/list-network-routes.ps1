<#
.SYNOPSIS
	Lists network routes
.DESCRIPTION
	This PowerShell script lists the network routes on the local computer.
.EXAMPLE
	PS> ./list-network-routes.ps1
.CATEGORY Network
#>

#Requires -Version 5.1

try {
	& route print
	exit 0
} catch {
throw
}
