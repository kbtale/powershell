<#
.SYNOPSIS
	Citrix: Gets configuration log service metadata
.DESCRIPTION
	Retrieves metadata associated with the configuration logging service.
.EXAMPLE
	PS> ./Get-CitrixLogServiceMetadata.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$metadata = Get-LogServiceMetadata -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}