<#
.SYNOPSIS
	Restarts the network adapters (needs admin rights)
.DESCRIPTION
	This PowerShell script restarts all local network adapters (needs admin rights).
.EXAMPLE
	PS> ./restart-network-adapters
.CATEGORY System
#>

#Requires -Version 5.1

#Requires -RunAsAdministrator

try {
	$StopWatch = [system.diagnostics.stopwatch]::startNew()

	Get-NetAdapter | Restart-NetAdapter 

	[int]$Elapsed = $StopWatch.Elapsed.TotalSeconds
	"✅ restarted all local network adapters in $Elapsed sec"
	exit 0
} catch {
throw
}
