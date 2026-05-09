<#
.SYNOPSIS
	Opens the OneDrive folder
.DESCRIPTION
	This script launches the File Explorer with the user's OneDrive folder.
.EXAMPLE
	PS> ./open-one-drive-folder.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	$TargetDirs = resolve-path "$HOME/OneDrive*"
	foreach($TargetDir in $TargetDirs) {
		& "$PSScriptRoot/open-file-explorer.ps1" "$TargetDir"
		exit 0
	}
	throw "No OneDrive folder at 📂$HOME/Dropbox"
} catch {
throw
}
