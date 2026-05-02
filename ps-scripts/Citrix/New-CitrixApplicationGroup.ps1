<#
.SYNOPSIS
	Citrix: Creates a new application group
.DESCRIPTION
	Creates a new group to manage sets of applications in the Citrix site.
.PARAMETER Name
	The name of the application group.
.EXAMPLE
	PS> ./New-CitrixApplicationGroup.ps1 -Name "Sales_Tools"
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