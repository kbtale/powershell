<#
.SYNOPSIS
	Removes all jobs from all printers
.DESCRIPTION
	This PowerShell script removes all print jobs from all printer devices.
.EXAMPLE
	PS> ./remove-print-jobs
.CATEGORY Utilities
#>

#Requires -Version 5.1

#Requires -Version 4

try {
	$printers = Get-Printer
	if ($printers.Count -eq 0) { throw "No printer found" }
		
	foreach ($printer in $printers) {
		$printjobs = Get-PrintJob -PrinterObject $printer
		foreach ($printjob in $printjobs) {
			Remove-PrintJob -InputObject $printjob
		}
	}

	"✅ all print jobs removed"
	exit 0
} catch {
throw
}
