<#
.SYNOPSIS
	Opens the desktop folder
.DESCRIPTION
	This PowerShell script launches the File Explorer with the user's desktop folder.
.EXAMPLE
	PS> ./open-desktop-folder.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	$TargetDir = resolve-path "$HOME/Desktop"
	if (-not(test-path "$TargetDir" -pathType container)) {
		throw "Desktop folder at 📂$TargetDir doesn't exist (yet)"
	}
	& "$PSScriptRoot/open-file-explorer.ps1" "$TargetDir"
	exit 0
} catch {
throw
}
