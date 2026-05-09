<#
.SYNOPSIS
	Opens the E: drive folder
.DESCRIPTION
	This PowerShell script launches the File Explorer with the E: drive folder.
.EXAMPLE
	PS> ./open-e-drive
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-file-explorer.ps1" "E:"
