<#
.SYNOPSIS
	Citrix: Updates an application
.DESCRIPTION
	Updates the properties or configuration of an existing Citrix application.
.PARAMETER Name
	The name of the application.
.PARAMETER Enabled
	Whether the application is enabled.
.EXAMPLE
	PS> ./Set-CitrixApplication.ps1 -Name "Notepad" -Enabled $true
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[bool]$Enabled
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerApplication -Name $Name -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated application '$Name'."
} catch {
	Write-Error $_
	exit 1
}