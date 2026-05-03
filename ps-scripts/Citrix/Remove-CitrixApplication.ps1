<#
.SYNOPSIS
	Citrix: Removes an application
.DESCRIPTION
	Deletes a registered application from the Citrix site.
.PARAMETER Name
	The name of the application to remove.
.EXAMPLE
	PS> ./Remove-CitrixApplication.ps1 -Name "OldApp"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerApplication -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed application '$Name'."
} catch {
	Write-Error $_
	exit 1
}