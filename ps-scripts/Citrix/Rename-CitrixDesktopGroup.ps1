<#
.SYNOPSIS
	Citrix: Renames a desktop group
.DESCRIPTION
	Changes the name of an existing Citrix desktop group.
.PARAMETER Name
	The current name of the group.
.PARAMETER NewName
	The new name for the group.
.EXAMPLE
	PS> ./Rename-CitrixDesktopGroup.ps1 -Name "Sales_Pool" -NewName "Sales_Desktops"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$NewName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Rename-BrokerDesktopGroup -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed desktop group '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}