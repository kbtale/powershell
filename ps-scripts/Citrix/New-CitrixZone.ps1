<#
.SYNOPSIS
	Citrix: Creates a new zone
.DESCRIPTION
	Adds a new zone to the Citrix site for geographic or logical grouping.
.PARAMETER Name
	The name of the new zone.
.EXAMPLE
	PS> ./New-CitrixZone.ps1 -Name "London"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$zone = New-BrokerZone -Name $Name -ErrorAction Stop
	Write-Output $zone
} catch {
	Write-Error $_
	exit 1
}