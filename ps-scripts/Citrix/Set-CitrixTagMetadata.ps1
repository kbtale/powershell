<#
.SYNOPSIS
	Citrix: Sets tag metadata
.DESCRIPTION
	Updates or adds metadata associated with a Citrix tag.
.PARAMETER TagName
	The name of the tag.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixTagMetadata.ps1 -TagName "Prod" -Map @{ 'Owner' = 'Ops' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$TagName,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerTagMetadata -Name $TagName -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for tag '$TagName'."
} catch {
	Write-Error $_
	exit 1
}