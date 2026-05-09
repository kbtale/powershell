<#
.SYNOPSIS
	Checks the validity of the Windows system files (requires admin rights)
.DESCRIPTION
	This PowerShell script checks the validity of the Windows system files. It requires admin rights.
.EXAMPLE
	PS> ./check-windows-system-files.ps1
		✅ checked Windows system files
.CATEGORY System
#>

#Requires -Version 5.1

#Requires -RunAsAdministrator

try {
	sfc /verifyOnly
	if ($lastExitCode -ne 0) { throw "'sfc /verifyOnly' failed" }

	"✅ checked Windows system files"
	exit 0
} catch {
throw
}
