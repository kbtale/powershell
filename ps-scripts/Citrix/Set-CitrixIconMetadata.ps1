<#
.SYNOPSIS
	Citrix: Sets icon metadata
.DESCRIPTION
	Updates or adds metadata associated with a specific Citrix icon.
.PARAMETER Id
	The unique ID of the icon.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixIconMetadata.ps1 -Id 1 -Map @{ 'Project' = 'VDI' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[int]$Id,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerIconMetadata -Uid $Id -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for icon '$Id'."
} catch {
	Write-Error $_
	exit 1
}