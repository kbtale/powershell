<#
.SYNOPSIS
	Citrix: Renames an application
.DESCRIPTION
	Changes the display name of an existing Citrix application.
.PARAMETER Name
	The current name of the application.
.PARAMETER NewName
	The new display name.
.EXAMPLE
	PS> ./Rename-CitrixApplication.ps1 -Name "Word" -NewName "Microsoft Word"
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
	Rename-BrokerApplication -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed application '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}