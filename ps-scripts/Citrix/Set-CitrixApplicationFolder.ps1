<#
.SYNOPSIS
	Citrix: Updates an application folder
.DESCRIPTION
	Updates the properties of a Citrix administrative application folder.
.PARAMETER Name
	The path to the folder.
.PARAMETER TotalApplicationsLimit
	Maximum number of applications allowed in this folder.
.EXAMPLE
	PS> ./Set-CitrixApplicationFolder.ps1 -Name "Finance" -TotalApplicationsLimit 50
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[int]$TotalApplicationsLimit
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerApplicationFolder -Name $Name -TotalApplicationsLimit $TotalApplicationsLimit -ErrorAction Stop
	Write-Output "Successfully updated application folder '$Name'."
} catch {
	Write-Error $_
	exit 1
}