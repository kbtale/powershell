<#
.SYNOPSIS
	Starts the Microsoft Store app
.DESCRIPTION
	This script launches the Microsoft Store application.
.EXAMPLE
	PS> ./open-microsoft-store.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

Start-Process ms-windows-store:
exit 0
