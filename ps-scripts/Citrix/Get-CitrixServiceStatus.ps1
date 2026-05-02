<#
.SYNOPSIS
	Citrix: Gets Citrix service status
.DESCRIPTION
	Retrieves the current operational status of Citrix services.
.PARAMETER ServiceType
	The type of service to check (optional).
.EXAMPLE
	PS> ./Get-CitrixServiceStatus.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$ServiceType
)

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($ServiceType) { $cmdArgs.Add('ServiceType', $ServiceType) }

	$status = Get-ConfigServiceStatus @cmdArgs
	Write-Output $status
} catch {
	Write-Error $_
	exit 1
}