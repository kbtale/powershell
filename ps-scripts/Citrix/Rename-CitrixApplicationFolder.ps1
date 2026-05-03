<#
.SYNOPSIS
	Citrix: Renames an application folder
.DESCRIPTION
	Changes the name of an existing Citrix application folder.
.PARAMETER Name
	The current path/name of the folder.
.PARAMETER NewName
	The new name for the folder.
.EXAMPLE
	PS> ./Rename-CitrixApplicationFolder.ps1 -Name "Finance" -NewName "Finance_Dept"
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
	Rename-BrokerApplicationFolder -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed application folder '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}