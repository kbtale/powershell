<#
.SYNOPSIS
	Closes the Snipping Tool
.DESCRIPTION
	This PowerShell script closes the Snipping Tool application gracefully.
.EXAMPLE
	PS> ./close-snipping-tool.ps1
.CATEGORY System
#>

#Requires -Version 5.1

& "$PSScriptRoot/close-program.ps1" "Snipping Tool" "SnippingTool.exe" ""
exit 0
