<#
.SYNOPSIS
	Citrix: Renames an application group
.DESCRIPTION
	Changes the name of an existing Citrix application group.
.PARAMETER Name
	The current name of the group.
.PARAMETER NewName
	The new name for the group.
.EXAMPLE
	PS> ./Rename-CitrixApplicationGroup.ps1 -Name "Sales" -NewName "Sales_Group"
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
	Rename-BrokerApplicationGroup -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed application group '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}