<#
.SYNOPSIS
	Citrix: Gets Citrix service instances
.DESCRIPTION
	Lists all instances of a specific service type in the Citrix site.
.PARAMETER ServiceType
	The type of service instance to list.
.EXAMPLE
	PS> ./Get-CitrixServiceInstance.ps1 -ServiceType Broker
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ServiceType
)

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	$instances = Get-ConfigServiceInstance -ServiceType $ServiceType -ErrorAction Stop
	Write-Output $instances
} catch {
	Write-Error $_
	exit 1
}