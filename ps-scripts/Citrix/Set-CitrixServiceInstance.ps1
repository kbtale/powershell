<#
.SYNOPSIS
	Citrix: Updates a service instance
.DESCRIPTION
	Updates the configuration of a specific Citrix service instance.
.PARAMETER ServiceType
	The type of the Citrix service.
.PARAMETER Metadata
	The metadata to update (hashtable).
.EXAMPLE
	PS> ./Set-CitrixServiceInstance.ps1 -ServiceType Broker -Metadata @{ 'Key' = 'Value' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ServiceType,

	[Parameter(Mandatory = $true)]
	[hashtable]$Metadata
)

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	Set-ConfigServiceInstance -ServiceType $ServiceType -Metadata $Metadata -ErrorAction Stop
	Write-Output "Successfully updated service instance '$ServiceType'."
} catch {
	Write-Error $_
	exit 1
}