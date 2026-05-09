<#
.SYNOPSIS
	Opens the Apps folder
.DESCRIPTION
	This PowerShell script launches the File Explorer showing the UWP apps folder.
.EXAMPLE
	PS> ./open-apps-folder
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-file-explorer.ps1" "shell:AppsFolder"
exit 0

