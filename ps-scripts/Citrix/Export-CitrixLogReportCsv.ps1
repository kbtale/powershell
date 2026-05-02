<#
.SYNOPSIS
	Citrix: Exports configuration log report to CSV
.DESCRIPTION
	Generates and exports a configuration logging report in CSV format.
.PARAMETER FilePath
	The destination path for the CSV file.
.EXAMPLE
	PS> ./Export-CitrixLogReportCsv.ps1 -FilePath "C:\Reports\ConfigLog.csv"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$FilePath
)

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$log = Get-LogHighLevelOperation -ErrorAction Stop
	$log | Export-Csv -Path $FilePath -NoTypeInformation -ErrorAction Stop
	Write-Output "Successfully exported log report to '$FilePath'."
} catch {
	Write-Error $_
	exit 1
}