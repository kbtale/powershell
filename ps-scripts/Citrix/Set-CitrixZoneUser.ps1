<#
.SYNOPSIS
	Citrix: Updates zone user properties
.DESCRIPTION
	Modifies properties of a user assigned to a specific Citrix zone.
.PARAMETER ZoneName
	The name of the zone.
.PARAMETER UserName
	The name of the user or group.
.EXAMPLE
	PS> ./Set-CitrixZoneUser.ps1 -ZoneName "London" -UserName "CONTOSO\Sales"
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
	Set-BrokerZoneUser -Name $ZoneName -UserName $UserName -ErrorAction Stop
	Write-Output "Successfully updated user '$UserName' in zone '$ZoneName'."
} catch {
	Write-Error $_
	exit 1
}