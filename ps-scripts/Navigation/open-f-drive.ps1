<#
.SYNOPSIS
	Opens the F: drive folder
.DESCRIPTION
	This PowerShell script launches the File Explorer with the F: drive folder.
.EXAMPLE
	PS> ./open-f-drive.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-file-explorer.ps1" "F:"
exit 0
