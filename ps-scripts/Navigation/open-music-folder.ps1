<#
.SYNOPSIS
	Opens the music folder
.DESCRIPTION
	This script launches the File Explorer with the user's music folder.
.EXAMPLE
	PS> ./open-music-folder.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	$TargetDir = Resolve-Path "$HOME/Music"
	if (-not(test-path "$TargetDir" -pathType container)) {
		throw "Music folder at 📂$TargetDir doesn't exist (yet)"
	}
	& "$PSScriptRoot/open-file-explorer.ps1" "$TargetDir"
	exit 0
} catch {
throw
}
