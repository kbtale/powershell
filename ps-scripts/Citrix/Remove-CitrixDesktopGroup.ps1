<#
.SYNOPSIS
	Citrix: Removes a desktop group
.DESCRIPTION
	Deletes an existing desktop group from the Citrix site.
.PARAMETER Name
	The name of the desktop group to remove.
.EXAMPLE
	PS> ./Remove-CitrixDesktopGroup.ps1 -Name "SalesPool"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerDesktopGroup -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed desktop group '$Name'."
} catch {
	Write-Error $_
	exit 1
}