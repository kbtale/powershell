<#
.SYNOPSIS
	Citrix: Removes icon metadata
.DESCRIPTION
	Deletes metadata associated with a specific Citrix icon.
.PARAMETER Id
	The unique ID of the icon.
.PARAMETER PropertyName
	The name of the metadata property to remove.
.EXAMPLE
	PS> ./Remove-CitrixIconMetadata.ps1 -Id 1 -PropertyName "Source"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[int]$Id,

	[Parameter(Mandatory = $true)]
	[string]$PropertyName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerIconMetadata -Uid $Id -Name $PropertyName -ErrorAction Stop
	Write-Output "Successfully removed metadata property '$PropertyName' from icon '$Id'."
} catch {
	Write-Error $_
	exit 1
}