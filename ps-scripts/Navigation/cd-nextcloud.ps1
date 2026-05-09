<#
.SYNOPSIS
	Sets the working directory to the user's NextCloud folder
.DESCRIPTION
	This PowerShell script changes the working directory to the user's NextCloud folder.
.EXAMPLE
	PS> ./cd-nextcloud.ps1
		📂C:\Users\Markus\NextCloud entered (has 2 files and 0 folder)
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	if (-not(Test-Path "~/NextCloud" -pathType container)) {
		throw "No 'NextCloud' folder in your home directory - Please install NextCloud"
	}
	$path = Resolve-Path "~/NextCloud"
	Set-Location "$path"
	$files = Get-ChildItem $path -attributes !Directory
	$folders = Get-ChildItem $path -attributes Directory
	"📂$path entered (has $($files.Count) files and $($folders.Count) folders)"
	exit 0
} catch {
throw
}
