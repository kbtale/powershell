<#
.SYNOPSIS
	Citrix: Moves an application
.DESCRIPTION
	Moves a Citrix application to a different application folder.
.PARAMETER ApplicationName
	The name of the application.
.PARAMETER DestinationFolder
	The path to the destination folder.
.EXAMPLE
	PS> ./Move-CitrixApplication.ps1 -ApplicationName "Notepad" -DestinationFolder "Finance\Tools"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ApplicationName,

	[Parameter(Mandatory = $true)]
	[string]$DestinationFolder
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerApplication -Name $ApplicationName -AdminFolder $DestinationFolder -ErrorAction Stop
	Write-Output "Successfully moved application '$ApplicationName' to '$DestinationFolder'."
} catch {
	Write-Error $_
	exit 1
}