<#
.SYNOPSIS
	Citrix: Gets configuration log site metadata
.DESCRIPTION
	Retrieves site-level metadata associated with configuration logging.
.EXAMPLE
	PS> ./Get-CitrixLogSiteMetadata.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$metadata = Get-LogSiteMetadata -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}