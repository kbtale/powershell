<#
.SYNOPSIS
	Citrix: Removes a user from a desktop group
.DESCRIPTION
	Deletes a user or group's access from a specified Citrix desktop group.
.PARAMETER UserName
	The name of the user or group (e.g. DOMAIN\User).
.PARAMETER DesktopGroupName
	The name of the desktop group.
.EXAMPLE
	PS> ./Remove-CitrixUser.ps1 -UserName "CONTOSO\SalesGroup" -DesktopGroupName "SalesPool"
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
	Remove-BrokerUser -Name $UserName -DesktopGroup $DesktopGroupName -ErrorAction Stop
	Write-Output "Successfully removed user '$UserName' from desktop group '$DesktopGroupName'."
} catch {
	Write-Error $_
	exit 1
}