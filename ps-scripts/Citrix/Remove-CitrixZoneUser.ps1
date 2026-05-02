<#
.SYNOPSIS
	Citrix: Removes a user from a zone
.DESCRIPTION
	Unassigns a user or group from a specific Citrix zone.
.PARAMETER ZoneName
	The name of the zone.
.PARAMETER UserName
	The name of the user or group to remove.
.EXAMPLE
	PS> ./Remove-CitrixZoneUser.ps1 -ZoneName "London" -UserName "CONTOSO\Sales"
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
	Remove-BrokerZoneUser -Name $ZoneName -UserName $UserName -ErrorAction Stop
	Write-Output "Successfully removed user '$UserName' from zone '$ZoneName'."
} catch {
	Write-Error $_
	exit 1
}