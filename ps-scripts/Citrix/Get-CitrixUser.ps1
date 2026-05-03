<#
.SYNOPSIS
	Citrix: Gets Citrix users
.DESCRIPTION
	Lists users and groups associated with Citrix resources.
.PARAMETER UserName
	The name of the user (optional).
.EXAMPLE
	PS> ./Get-CitrixUser.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$UserName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($UserName) { $cmdArgs.Add('Name', $UserName) }

	$users = Get-BrokerUser @cmdArgs
	Write-Output $users
} catch {
	Write-Error $_
	exit 1
}