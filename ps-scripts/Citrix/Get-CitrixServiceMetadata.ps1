<#
.SYNOPSIS
	Citrix: Gets service metadata
.DESCRIPTION
	Retrieves metadata associated with a Citrix service.
.PARAMETER ServiceType
	The type of Citrix service.
.EXAMPLE
	PS> ./Get-CitrixServiceMetadata.ps1 -ServiceType Broker
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ServiceType
)

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	$metadata = Get-ConfigServiceMetadata -ServiceType $ServiceType -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}