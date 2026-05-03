<#
.SYNOPSIS
	Citrix: Adds an application to a group
.DESCRIPTION
	Associates an existing Citrix application with a specific application group.
.PARAMETER ApplicationName
	The name of the application.
.PARAMETER GroupName
	The name of the application group.
.EXAMPLE
	PS> ./Add-CitrixApplicationToGroup.ps1 -ApplicationName "Notepad" -GroupName "Utils"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ApplicationName,

	[Parameter(Mandatory = $true)]
	[string]$GroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Add-BrokerApplication -Name $ApplicationName -ApplicationGroup $GroupName -ErrorAction Stop
	Write-Output "Successfully added application '$ApplicationName' to group '$GroupName'."
} catch {
	Write-Error $_
	exit 1
}