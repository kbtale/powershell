<#
.SYNOPSIS
	Launches the Microsoft Paint app
.DESCRIPTION
	This script launches the Microsoft Paint application.
.EXAMPLE
	PS> ./open-microsoft-paint.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	start-process mspaint.exe
	exit 0
} catch {
throw
}
