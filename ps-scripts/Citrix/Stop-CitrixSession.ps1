<#
.SYNOPSIS
	Citrix: Stops a Citrix session
.DESCRIPTION
	Forces a logoff of an active Citrix user session.
.PARAMETER SessionId
	The unique ID of the session to stop.
.EXAMPLE
	PS> ./Stop-CitrixSession.ps1 -SessionId 123
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[int]$SessionId
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Stop-BrokerSession -SessionId $SessionId -ErrorAction Stop
	Write-Output "Successfully stopped session '$SessionId'."
} catch {
	Write-Error $_
	exit 1
}