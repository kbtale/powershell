<#
.SYNOPSIS
	Lists all print jobs
.DESCRIPTION
	This PowerShell script lists all print jobs of all printer devices.
.EXAMPLE
	PS> ./list-print-jobs.ps1
		Printer                       Jobs
		-------                       ----
		ET-2810 Series 		      none
.CATEGORY System
#>

#Requires -Version 5.1

#Requires -Version 4

function ListPrintJobs {
	$printers = Get-Printer
	if ($printers.Count -eq 0) { throw "No printer found" }

	foreach ($printer in $printers) {
		$PrinterName = $printer.Name
		$printjobs = Get-PrintJob -PrinterObject $printer
		if ($printjobs.Count -eq 0) {
			$PrintJobs = "none"
		} else {
			$PrintJobs = "$printjobs"
		}
		New-Object PSObject -Property @{ Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss"); Printer=$PrinterName; Jobs=$PrintJobs }
	}
}

try {
	if ($IsLinux) {
		# TODO
	} else {
		ListPrintJobs | Format-Table -property Printer,Jobs
	}
	exit 0
} catch {
throw
}
