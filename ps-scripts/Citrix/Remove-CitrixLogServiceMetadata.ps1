<#
.SYNOPSIS
	Citrix: Removes configuration log service metadata
.DESCRIPTION
	Deletes metadata associated with the configuration logging service.
.PARAMETER PropertyName
	The name of the metadata property to remove.
.EXAMPLE
	PS> ./Remove-CitrixLogServiceMetadata.ps1 -PropertyName "Source"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$PropertyName
)

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	Remove-LogServiceMetadata -Name $PropertyName -ErrorAction Stop
	Write-Output "Successfully removed service metadata property '$PropertyName'."
} catch {
	Write-Error $_
	exit 1
}