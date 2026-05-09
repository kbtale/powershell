<#
.SYNOPSIS
	Opens the home folder
.DESCRIPTION
	This script launches the File Explorer with the user's home folder.
.EXAMPLE
	PS> ./open-home-folder.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	$TargetDir = resolve-path "$HOME"
	if (-not(test-path "$TargetDir" -pathType container)) {
		throw "Home folder at 📂$TargetDir doesn't exist (yet)"
	}
	& "$PSScriptRoot/open-file-explorer.ps1" "$TargetDir"
	exit 0
} catch {
throw
}
