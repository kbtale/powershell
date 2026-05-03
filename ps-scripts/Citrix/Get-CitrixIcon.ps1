<#
.SYNOPSIS
	Citrix: Gets a Citrix icon
.DESCRIPTION
	Retrieves a specific icon registered in the Citrix site by its unique ID.
.PARAMETER Id
	The unique ID of the icon.
.EXAMPLE
	PS> ./Get-CitrixIcon.ps1 -Id 1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[int]$Id
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$icon = Get-BrokerIcon -Uid $Id -ErrorAction Stop
	Write-Output $icon
} catch {
	Write-Error $_
	exit 1
}