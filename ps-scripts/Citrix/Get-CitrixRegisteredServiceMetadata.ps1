<#
.SYNOPSIS
	Citrix: Gets registered service metadata
.DESCRIPTION
	Retrieves metadata for all registered services in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixRegisteredServiceMetadata.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	$metadata = Get-ConfigRegisteredServiceInstance -ErrorAction Stop | Select-Object ServiceType, Metadata
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}