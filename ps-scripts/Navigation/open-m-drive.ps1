<#
.SYNOPSIS
	Opens the M: drive folder
.DESCRIPTION
	This script launches the File Explorer with the M: drive folder.
.EXAMPLE
	PS> ./open-m-drive.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-file-explorer.ps1" "M:"
exit 0
