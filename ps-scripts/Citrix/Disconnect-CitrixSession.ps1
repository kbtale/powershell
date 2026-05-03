<#
.SYNOPSIS
	Citrix: Disconnects a session
.DESCRIPTION
	Disconnects an active Citrix user session.
.PARAMETER SessionId
	The unique ID of the session to disconnect.
.EXAMPLE
	PS> ./Disconnect-CitrixSession.ps1 -SessionId 42
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[int]$SessionId
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Disconnect-BrokerSession -SessionId $SessionId -ErrorAction Stop
	Write-Output "Successfully disconnected session '$SessionId'."
} catch {
	Write-Error $_
	exit 1
}