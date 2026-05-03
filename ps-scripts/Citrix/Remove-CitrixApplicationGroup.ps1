<#
.SYNOPSIS
	Citrix: Removes an application group
.DESCRIPTION
	Deletes an existing application group from the Citrix site.
.PARAMETER Name
	The name of the application group to remove.
.EXAMPLE
	PS> ./Remove-CitrixApplicationGroup.ps1 -Name "Deprecated_Apps"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerApplicationGroup -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed application group '$Name'."
} catch {
	Write-Error $_
	exit 1
}