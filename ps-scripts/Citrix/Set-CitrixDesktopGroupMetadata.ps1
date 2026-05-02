<#
.SYNOPSIS
	Citrix: Sets desktop group metadata
.DESCRIPTION
	Updates or adds metadata associated with a Citrix desktop group.
.PARAMETER GroupName
	The name of the desktop group.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixDesktopGroupMetadata.ps1 -GroupName "SalesPool" -Map @{ 'Dept' = 'Sales' }
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
	Set-BrokerDesktopGroupMetadata -Name $GroupName -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for desktop group '$GroupName'."
} catch {
	Write-Error $_
	exit 1
}