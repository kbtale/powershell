<#
.SYNOPSIS
	Citrix: Updates an application group
.DESCRIPTION
	Updates the properties or status of an existing Citrix application group.
.PARAMETER Name
	The name of the application group.
.PARAMETER Enabled
	Whether the group is enabled.
.EXAMPLE
	PS> ./Set-CitrixApplicationGroup.ps1 -Name "Office_Apps" -Enabled $true
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[bool]$Enabled
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerApplicationGroup -Name $Name -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated application group '$Name'."
} catch {
	Write-Error $_
	exit 1
}