<#
.SYNOPSIS
	Opens the Dropbox folder
.DESCRIPTION
	This PowerShell script launches the File Explorer with the user's Dropbox folder.
.EXAMPLE
	PS> ./open-dropbox-folder
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	$TargetDirs = resolve-path "$HOME/Dropbox*"
	foreach($TargetDir in $TargetDirs) {
		& "$PSScriptRoot/open-file-explorer.ps1" "$TargetDir"
		exit 0
	}
	throw "No Dropbox folder at 📂$HOME/Dropbox"
} catch {
throw
}
