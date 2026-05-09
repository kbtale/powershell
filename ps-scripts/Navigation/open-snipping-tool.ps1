<#
.SYNOPSIS
	Starts the Snipping Tool
.DESCRIPTION
	This script launches the Snipping Tool application.
.EXAMPLE
	PS> ./open-snipping-tool.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

Start-Process SnippingTool.exe
exit 0
