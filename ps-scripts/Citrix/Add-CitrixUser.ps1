<#
.SYNOPSIS
	Citrix: Adds a user to a desktop group
.DESCRIPTION
	Grants a user or group access to a Citrix desktop group.
.PARAMETER UserName
	The name of the user or group (e.g. DOMAIN\User).
.PARAMETER DesktopGroupName
	The name of the desktop group.
.EXAMPLE
	PS> ./Add-CitrixUser.ps1 -UserName "CONTOSO\SalesGroup" -DesktopGroupName "Sales_Pool"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$UserName,

	[Parameter(Mandatory = $true)]
	[string]$DesktopGroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Add-BrokerUser -Name $UserName -DesktopGroup $DesktopGroupName -ErrorAction Stop
	Write-Output "Successfully added user '$UserName' to desktop group '$DesktopGroupName'."
} catch {
	Write-Error $_
	exit 1
}