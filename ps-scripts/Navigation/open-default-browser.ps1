<#
.SYNOPSIS
	Opens the default browser
.DESCRIPTION
	This PowerShell script launches the default Web browser, optional with a given URL.
.PARAMETER URL
	Specifies the URL
.EXAMPLE
	PS> ./open-default-browser.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

param([string]$URL = "https://www.fleschutz.de")

try {
	Start-Process $URL
	exit 0
} catch {
throw
}
