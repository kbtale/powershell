<#
.SYNOPSIS
	Citrix: Sets service metadata
.DESCRIPTION
	Updates or adds metadata associated with a Citrix service.
.PARAMETER ServiceType
	The type of the Citrix service.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixServiceMetadata.ps1 -ServiceType Broker -Map @{ 'Ver' = '1.2' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ServiceType,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	Set-ConfigServiceMetadata -ServiceType $ServiceType -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for service '$ServiceType'."
} catch {
	Write-Error $_
	exit 1
}