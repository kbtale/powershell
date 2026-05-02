<#
.SYNOPSIS
	Citrix: Gets a report of application folders
.DESCRIPTION
	Retrieves a summarized list of all application folders in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixApplicationFolderReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$folders = Get-BrokerApplicationFolder -ErrorAction Stop | Select-Object Name, TotalApplicationsLimit, ParentAdminFolderName
	Write-Output $folders
} catch {
	Write-Error $_
	exit 1
}