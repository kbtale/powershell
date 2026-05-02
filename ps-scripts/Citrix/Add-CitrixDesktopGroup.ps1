<#
.SYNOPSIS
	Citrix: Adds a Citrix desktop group
.DESCRIPTION
	Creates a new desktop group in the Citrix site.
.PARAMETER Name
	The name of the desktop group.
.PARAMETER PublishedName
	The name displayed to users.
.EXAMPLE
	PS> ./Add-CitrixDesktopGroup.ps1 -Name "Sales_Pool" -PublishedName "Sales Desktops"
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
	$group = New-BrokerDesktopGroup -Name $Name -PublishedName $PublishedName -ErrorAction Stop
	Write-Output $group
} catch {
	Write-Error $_
	exit 1
}