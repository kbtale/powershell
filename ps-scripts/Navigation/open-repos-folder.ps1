<#
.SYNOPSIS
	Opens the Git repositories folder
.DESCRIPTION
	This script launches the File Explorer with the user's Git repositories folder.
.EXAMPLE
	PS> ./open-repos-folder.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	$TargetDir = Resolve-Path "$HOME/Repos"
	if (-not(Test-Path "$TargetDir" -pathType container)) {
		throw "Repos folder at 📂$TargetDir doesn't exist (yet)"
	}
	& "$PSScriptRoot/open-file-explorer.ps1" "$TargetDir"
	exit 0
} catch {
throw
}
