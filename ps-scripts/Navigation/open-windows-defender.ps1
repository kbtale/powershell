<#
.SYNOPSIS
	Launches Windows Defender
.DESCRIPTION
	This script launches the Windows Defender application.
.EXAMPLE
	PS> ./open-windows-defender.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

Start-Process windowsdefender:
exit 0
