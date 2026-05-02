<#
.SYNOPSIS
	Citrix: Gets Citrix services
.DESCRIPTION
	Lists the registered services within the Citrix site.
.PARAMETER ServiceName
	The name of the service (optional).
.EXAMPLE
	PS> ./Get-CitrixService.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$ServiceName
)

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($ServiceName) { $cmdArgs.Add('ServiceType', $ServiceName) }

	$services = Get-ConfigService @cmdArgs
	Write-Output $services
} catch {
	Write-Error $_
	exit 1
}