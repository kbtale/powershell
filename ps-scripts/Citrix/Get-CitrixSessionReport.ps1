<#
.SYNOPSIS
	Citrix: Gets a report of user sessions
.DESCRIPTION
	Retrieves a summarized list of active and disconnected Citrix user sessions.
.EXAMPLE
	PS> ./Get-CitrixSessionReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$sessions = Get-BrokerSession -ErrorAction Stop | Select-Object UserName, MachineName, SessionState, StartTime, Protocol
	Write-Output $sessions
} catch {
	Write-Error $_
	exit 1
}