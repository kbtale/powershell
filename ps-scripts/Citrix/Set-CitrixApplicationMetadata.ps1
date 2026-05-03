<#
.SYNOPSIS
	Citrix: Sets application metadata
.DESCRIPTION
	Updates or adds metadata associated with a Citrix application.
.PARAMETER ApplicationName
	The name of the application.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixApplicationMetadata.ps1 -ApplicationName "Notepad" -Map @{ 'Type' = 'Utility' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ApplicationName,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerApplicationMetadata -Name $ApplicationName -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for application '$ApplicationName'."
} catch {
	Write-Error $_
	exit 1
}