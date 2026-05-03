<#
.SYNOPSIS
	Citrix: Removes desktop group metadata
.DESCRIPTION
	Deletes metadata associated with a Citrix desktop group.
.PARAMETER Name
	The name of the desktop group.
.PARAMETER PropertyName
	The name of the metadata property to remove.
.EXAMPLE
	PS> ./Remove-CitrixDesktopGroupMetadata.ps1 -Name "SalesPool" -PropertyName "Region"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$PropertyName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerDesktopGroupMetadata -Name $Name -Name $PropertyName -ErrorAction Stop
	Write-Output "Successfully removed metadata property '$PropertyName' from desktop group '$Name'."
} catch {
	Write-Error $_
	exit 1
}