<#
.SYNOPSIS
	Opens Google Books
.DESCRIPTION
	This PowerShell script launches the Web browser with the Google Books website.
.EXAMPLE
	PS> ./open-google-books.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://books.google.com"
exit 0
