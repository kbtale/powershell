<#
.SYNOPSIS
	Sets the working dir to the users directory
.DESCRIPTION
	This PowerShell script sets the current working directory to the users directory.
.EXAMPLE
	PS> ./cd-users.ps1
		📂C:\Users with 4 folders entered.
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	$path = Resolve-Path "~/.."
	if (-not(Test-Path "$path" -pathType container)) { throw "No users directory at: $path" }

	Set-Location "$path"
	$folders = Get-ChildItem $path -attributes Directory
	"📂$path with $($folders.Count) folders entered."
	exit 0
} catch {
throw
}
