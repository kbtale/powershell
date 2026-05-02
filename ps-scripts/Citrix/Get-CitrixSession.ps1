<#
.SYNOPSIS
	Citrix: Gets Citrix sessions
.DESCRIPTION
	Lists active and disconnected user sessions in the Citrix site.
.PARAMETER UserName
	The name of the user (optional).
.EXAMPLE
	PS> ./Get-CitrixSession.ps1 -UserName "CONTOSO\User1"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$UserName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($UserName) { $cmdArgs.Add('UserName', $UserName) }

	$sessions = Get-BrokerSession @cmdArgs
	Write-Output $sessions
} catch {
	Write-Error $_
	exit 1
}