<#
.SYNOPSIS
	Opens the D: drive folder
.DESCRIPTION
	This PowerShell script launches the File Explorer with the D: drive folder.
.EXAMPLE
	PS> ./open-d-drive
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-file-explorer.ps1" "D:"
