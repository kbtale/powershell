<#
.SYNOPSIS
	Citrix: Gets a report of applications
.DESCRIPTION
	Retrieves a summarized list of all applications registered in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixApplicationReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$apps = Get-BrokerApplication -ErrorAction Stop | Select-Object Name, Enabled, CommandLineExecutable, ApplicationType
	Write-Output $apps
} catch {
	Write-Error $_
	exit 1
}