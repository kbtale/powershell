<#
.SYNOPSIS
	Opens the C: drive folder
.DESCRIPTION
	This PowerShell script launches the File Explorer with the C: drive folder.
.EXAMPLE
	PS> ./open-c-drive
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-file-explorer.ps1" "C:"
exit 0
