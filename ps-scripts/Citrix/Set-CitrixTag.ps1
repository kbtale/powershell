<#
.SYNOPSIS
	Citrix: Updates a tag
.DESCRIPTION
	Updates the properties or description of an existing Citrix tag.
.PARAMETER Name
	The name of the tag.
.PARAMETER Description
	The new description for the tag.
.EXAMPLE
	PS> ./Set-CitrixTag.ps1 -Name "Prod" -Description "Production resources only"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$Description
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerTag -Name $Name -Description $Description -ErrorAction Stop
	Write-Output "Successfully updated tag '$Name'."
} catch {
	Write-Error $_
	exit 1
}