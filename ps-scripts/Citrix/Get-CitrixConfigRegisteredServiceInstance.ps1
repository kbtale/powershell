<#
.SYNOPSIS
	Citrix: Gets registered service instances
.DESCRIPTION
	Retrieves a list of all services registered within the Citrix configuration.
.EXAMPLE
	PS> ./Get-CitrixConfigRegisteredServiceInstance.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	$services = Get-ConfigRegisteredServiceInstance -ErrorAction Stop
	Write-Output $services
} catch {
	Write-Error $_
	exit 1
}