<#
.SYNOPSIS
	Launches the File Explorer
.DESCRIPTION
	This PowerShell script launches the File Explorer.
.PARAMETER Path
	Specifies the path to the folder to display
.EXAMPLE
	PS> ./open-file-explorer
.CATEGORY Navigation
#>

#requires -version 5.1

param([string]$Path = "")

try {
	if ("$Path" -ne "") {
		start-process explorer.exe "$Path"
	} else {
		start-process explorer.exe
	}
	exit 0
} catch {
throw
}
