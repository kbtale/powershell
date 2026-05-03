<#
.SYNOPSIS
	Citrix: Creates a new tag
.DESCRIPTION
	Creates a new tag in the Citrix site for resource organization.
.PARAMETER Name
	The name of the tag.
.EXAMPLE
	PS> ./New-CitrixTag.ps1 -Name "Cloud_Ready"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	New-BrokerTag -Name $Name -ErrorAction Stop
	Write-Output "Successfully created tag '$Name'."
} catch {
	Write-Error $_
	exit 1
}