<#
.SYNOPSIS
	Launches the Windows Terminal app
.DESCRIPTION
	This script launches the Windows Terminal application.
.EXAMPLE
	PS> ./open-windows-terminal.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

Start-Process wt.exe
exit 0
