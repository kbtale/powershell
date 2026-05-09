<#
.SYNOPSIS
	Sets the working dir to the fonts folder
.DESCRIPTION
	This PowerShell script sets the current working directory to the fonts folder.
.EXAMPLE
	PS> ./cd-fonts.ps1
		📂C:\Windows\Fonts with 12 font files entered.
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	$path = [Environment]::GetFolderPath('Fonts')
	if (-not(Test-Path "$path" -pathType container)) {
		throw "No fonts folder at: $path"
	}
	Set-Location "$path"
	$files = Get-ChildItem $path -attributes !Directory
	"📂$path with $($files.Count) font files entered."
	exit 0
} catch {
throw
}
