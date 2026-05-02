<#
.SYNOPSIS
	Citrix: Sets application group metadata
.DESCRIPTION
	Updates or adds metadata associated with a Citrix application group.
.PARAMETER GroupName
	The name of the application group.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixApplicationGroupMetadata.ps1 -GroupName "Office_Apps" -Map @{ 'Owner' = 'IT' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$GroupName,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerApplicationGroupMetadata -Name $GroupName -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for application group '$GroupName'."
} catch {
	Write-Error $_
	exit 1
}