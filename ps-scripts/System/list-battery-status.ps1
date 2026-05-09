<#
.SYNOPSIS
	Lists the battery status
.DESCRIPTION
	This PowerShell script lists the battery status.
.EXAMPLE
	PS> ./list-battery-status.ps1
		PowerLineStatus      : Online
		BatteryChargeStatus  : NoSystemBattery
.CATEGORY System
#>

#Requires -Version 5.1

try {
	Add-Type -Assembly System.Windows.Forms
	[System.Windows.Forms.SystemInformation]::PowerStatus
	exit 0
} catch {
throw
}
