<#
.SYNOPSIS
	Citrix: Renames a tag
.DESCRIPTION
	Changes the name of an existing Citrix tag.
.PARAMETER Name
	The current name of the tag.
.PARAMETER NewName
	The new name for the tag.
.EXAMPLE
	PS> ./Rename-CitrixTag.ps1 -Name "Legacy" -NewName "Archived"
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
	Rename-BrokerTag -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed tag '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}