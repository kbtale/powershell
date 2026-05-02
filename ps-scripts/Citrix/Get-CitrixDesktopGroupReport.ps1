<#
.SYNOPSIS
	Citrix: Gets desktop group report
.DESCRIPTION
	Retrieves a summarized report of all desktop groups in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixDesktopGroupReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$report = Get-BrokerDesktopGroup -ErrorAction Stop | Select-Object Name, PublishedName, DesktopKind, SessionSupport
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}