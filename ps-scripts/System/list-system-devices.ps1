<#
.SYNOPSIS
	Lists system devices
.DESCRIPTION
	This PowerShell script lists all system devices connected to the local computer.
.EXAMPLE
	PS> ./list-system-devices.ps1
		FriendlyName                 Status  InstanceId
		------------                 ------  ----------
		Microsoft-Controller         OK      ROOT\SPACEPORT\0000
.CATEGORY System
#>

#Requires -Version 5.1

try {
	Get-PnpDevice | Where-Object {$_.Class -like "System"} | Format-Table -property FriendlyName,Status,InstanceId
	exit 0
} catch {
throw
}
