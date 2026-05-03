<#
.SYNOPSIS
	Citrix: Removes application group metadata
.DESCRIPTION
	Deletes metadata associated with a Citrix application group.
.PARAMETER Name
	The name of the application group.
.PARAMETER PropertyName
	The name of the metadata property to remove.
.EXAMPLE
	PS> ./Remove-CitrixApplicationGroupMetadata.ps1 -Name "Office" -PropertyName "InternalID"
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
	Remove-BrokerApplicationGroupMetadata -Name $Name -Name $PropertyName -ErrorAction Stop
	Write-Output "Successfully removed metadata property '$PropertyName' from group '$Name'."
} catch {
	Write-Error $_
	exit 1
}