<#
.SYNOPSIS
	Citrix: Sets application folder metadata
.DESCRIPTION
	Updates or adds metadata associated with a Citrix application folder.
.PARAMETER FolderPath
	The path to the folder.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixApplicationFolderMetadata.ps1 -FolderPath "Finance" -Map @{ 'Org' = 'FIN' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$FolderPath,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerApplicationFolderMetadata -Name $FolderPath -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for application folder '$FolderPath'."
} catch {
	Write-Error $_
	exit 1
}