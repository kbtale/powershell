<#
.SYNOPSIS
	Citrix: Exports configuration log report to HTML
.DESCRIPTION
	Generates and exports a configuration logging report in HTML format.
.PARAMETER FilePath
	The destination path for the HTML file.
.EXAMPLE
	PS> ./Export-CitrixLogReportHtml.ps1 -FilePath "C:\Reports\ConfigLog.html"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$FilePath
)

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$log = Get-LogHighLevelOperation -ErrorAction Stop
	$log | ConvertTo-Html | Out-File -FilePath $FilePath -ErrorAction Stop
	Write-Output "Successfully exported log report to '$FilePath'."
} catch {
	Write-Error $_
	exit 1
}