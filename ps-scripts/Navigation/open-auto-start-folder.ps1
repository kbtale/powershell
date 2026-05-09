<#
.SYNOPSIS
	Opens the autostart folder
.DESCRIPTION
	This PowerShell script launches the File Explorer with the user's autostart folder.
.EXAMPLE
	PS> ./open-auto-start-folder
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	$TargetDir = resolve-path "$HOME/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup"
	if (-not(test-path "$TargetDir" -pathType container)) {
		throw "Autostart folder at 📂$TargetDir doesn't exist (yet)"
	}
	& "$PSScriptRoot/open-file-explorer.ps1" "$TargetDir"
	exit 0
} catch {
throw
}
