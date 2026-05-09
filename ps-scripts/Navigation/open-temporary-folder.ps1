<#
.SYNOPSIS
	Opens the temporary folder
.DESCRIPTION
	This script launches the File Explorer showing the temporary folder.
.EXAMPLE
	PS> ./open-temporary-folder.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

function GetTempDir {
	if ("$env:TEMP" -ne "")	{ return "$env:TEMP" }
	if ("$env:TMP" -ne "")	{ return "$env:TMP" }
	if ($IsLinux) { return "/tmp" }
	return "C:\Temp"
}

try {
	$Path = GetTempDir
	if (-not(test-path "$Path" -pathType container)) {
		throw "Temporary folder at 📂$Path doesn't exist (yet)"
	}
	& "$PSScriptRoot/open-file-explorer.ps1" "$Path"
	exit 0
} catch {
throw
}
