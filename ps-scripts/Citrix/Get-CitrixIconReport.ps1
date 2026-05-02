<#
.SYNOPSIS
	Citrix: Gets a report of Citrix icons
.DESCRIPTION
	Retrieves a summarized list of all icons registered in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixIconReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$icons = Get-BrokerIcon -ErrorAction Stop | Select-Object Uid, EncodedIconData
	Write-Output $icons
} catch {
	Write-Error $_
	exit 1
}