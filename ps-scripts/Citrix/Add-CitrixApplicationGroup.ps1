<#
.SYNOPSIS
	Citrix: Adds a Citrix application group
.DESCRIPTION
	Creates a new application group in the Citrix site.
.PARAMETER Name
	The name of the application group.
.EXAMPLE
	PS> ./Add-CitrixApplicationGroup.ps1 -Name "Office_Apps"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$group = New-BrokerApplicationGroup -Name $Name -ErrorAction Stop
	Write-Output $group
} catch {
	Write-Error $_
	exit 1
}