<#
.SYNOPSIS
	Create an empty file
.DESCRIPTION
	This PowerShell script creates a new empty file.
.PARAMETER filename
	Path and filename of the new file
.EXAMPLE
	PS> ./touch.ps1 test.txt
		✅ Created a new empty file called 'test.txt'.
.CATEGORY Utilities
#>

#Requires -Version 5.1

param([string]$filename = "")

try {
	if ($filename -eq "") { $filename = Read-Host "Enter the filename" }
	"" | Out-File $filename -encoding ASCII
	"✅ Created a new empty file called '$filename'."
	exit 0
} catch {
throw
}
