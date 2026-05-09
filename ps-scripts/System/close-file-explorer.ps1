<#
.SYNOPSIS
	Closes the File Explorer
.DESCRIPTION
	This PowerShell script closes the Microsoft File Explorer application gracefully.
.EXAMPLE
	PS> ./close-file-explorer
.CATEGORY System
#>

#Requires -Version 5.1

(New-Object -ComObject Shell.Application).Windows() | %{$_.quit()}
exit 0
