<#
.SYNOPSIS
	Citrix: Creates a new desktop group
.DESCRIPTION
	Creates a new delivery group for desktops or applications in the Citrix site.
.PARAMETER Name
	The name of the desktop group.
.PARAMETER PublishedName
	The name visible to users.
.EXAMPLE
	PS> ./New-CitrixDesktopGroup.ps1 -Name "HR_Pool" -PublishedName "HR Desktops"
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