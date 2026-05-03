<#
.SYNOPSIS
	Citrix: Removes an application folder
.DESCRIPTION
	Deletes an administrative application folder from the Citrix site.
.PARAMETER Name
	The path to the folder to remove.
.EXAMPLE
	PS> ./Remove-CitrixApplicationFolder.ps1 -Name "Finance\Temp"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerApplicationFolder -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed application folder '$Name'."
} catch {
	Write-Error $_
	exit 1
}