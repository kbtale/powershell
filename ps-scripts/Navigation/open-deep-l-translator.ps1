<#
.SYNOPSIS
	Opens the DeepL Translator website
.DESCRIPTION
	This PowerShell script launches the Web browser with the DeepL Translator website.
.EXAMPLE
	PS> ./open-deep-l-translator.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://www.deepl.com/translator"
exit 0
