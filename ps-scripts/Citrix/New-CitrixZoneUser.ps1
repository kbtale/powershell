<#
.SYNOPSIS
	Citrix: Adds a user to a zone
.DESCRIPTION
	Assigns a user or group to a specific Citrix zone.
.PARAMETER ZoneName
	The name of the zone.
.PARAMETER UserName
	The name of the user or group to add.
.EXAMPLE
	PS> ./New-CitrixZoneUser.ps1 -ZoneName "London" -UserName "CONTOSO\Sales"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ZoneName,

	[Parameter(Mandatory = $true)]
	[string]$UserName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$user = Add-BrokerZoneUser -Name $ZoneName -UserName $UserName -ErrorAction Stop
	Write-Output $user
} catch {
	Write-Error $_
	exit 1
}