<#
.SYNOPSIS
	Citrix: Gets Citrix icon data
.DESCRIPTION
	Retrieves the raw image data for a specific Citrix icon.
.PARAMETER Id
	The unique ID of the icon.
.EXAMPLE
	PS> ./Get-CitrixIconData.ps1 -Id 1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[int]$Id
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$icon = Get-BrokerIcon -Uid $Id -ErrorAction Stop
	Write-Output $icon.EncodedIconData
} catch {
	Write-Error $_
	exit 1
}