<#
.SYNOPSIS
	Citrix: Updates a desktop group
.DESCRIPTION
	Updates the properties or status of an existing Citrix desktop group.
.PARAMETER Name
	The name of the group.
.PARAMETER PublishedName
	The name displayed to users.
.EXAMPLE
	PS> ./Set-CitrixDesktopGroup.ps1 -Name "SalesPool" -PublishedName "Sales Desktops (New)"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$PublishedName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerDesktopGroup -Name $Name -PublishedName $PublishedName -ErrorAction Stop
	Write-Output "Successfully updated desktop group '$Name'."
} catch {
	Write-Error $_
	exit 1
}