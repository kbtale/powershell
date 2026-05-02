<#
.SYNOPSIS
	Citrix: Removes a tag
.DESCRIPTION
	Deletes a tag from the Citrix site configuration.
.PARAMETER Name
	The name of the tag to remove.
.EXAMPLE
	PS> ./Remove-CitrixTag.ps1 -Name "Obsolete_Tag"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerTag -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed tag '$Name'."
} catch {
	Write-Error $_
	exit 1
}