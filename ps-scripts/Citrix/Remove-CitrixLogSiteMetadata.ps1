<#
.SYNOPSIS
	Citrix: Removes configuration log site metadata
.DESCRIPTION
	Deletes site-level metadata associated with configuration logging.
.PARAMETER PropertyName
	The name of the metadata property to remove.
.EXAMPLE
	PS> ./Remove-CitrixLogSiteMetadata.ps1 -PropertyName "TenantId"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$PropertyName
)

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	Remove-LogSiteMetadata -Name $PropertyName -ErrorAction Stop
	Write-Output "Successfully removed site metadata property '$PropertyName'."
} catch {
	Write-Error $_
	exit 1
}