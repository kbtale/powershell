<#
.SYNOPSIS
	Citrix: Removes a Citrix icon
.DESCRIPTION
	Deletes an existing icon from the Citrix site configuration.
.PARAMETER Id
	The unique ID of the icon to remove.
.EXAMPLE
	PS> ./Remove-CitrixIcon.ps1 -Id 5
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[int]$Id
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerIcon -Uid $Id -Force -ErrorAction Stop
	Write-Output "Successfully removed icon '$Id'."
} catch {
	Write-Error $_
	exit 1
}