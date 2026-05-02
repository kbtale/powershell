<#
.SYNOPSIS
	Citrix: Gets Citrix desktop groups
.DESCRIPTION
	Lists desktop groups defined in the Citrix site.
.PARAMETER Name
	The name of the desktop group (optional).
.EXAMPLE
	PS> ./Get-CitrixDesktopGroup.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($Name) { $cmdArgs.Add('Name', $Name) }

	$groups = Get-BrokerDesktopGroup @cmdArgs
	Write-Output $groups
} catch {
	Write-Error $_
	exit 1
}