<#
.SYNOPSIS
	Checks PnP devices
.DESCRIPTION
	This PowerShell script checks all Plug'n'PLay devices connected to the local computer.
.EXAMPLE
	PS> ./check-pnp-devices.ps1
		FriendlyName                 Status  InstanceId
		------------                 ------  ----------
		Microsoft-Controller         OK      ROOT\SPACEPORT\0000
.CATEGORY System
#>

#Requires -Version 5.1

try {
	Get-PnpDevice | Where-Object {$_.Status -like "Error"} | Format-Table -property FriendlyName,Status,InstanceId
	exit 0
} catch {
throw
}
