<#
.SYNOPSIS
	Lists window titles
.DESCRIPTION
	This PowerShell script queries all main window titles and lists them as a table.
.EXAMPLE
	PS> ./list-window-titles.ps1
		   Id ProcessName          MainWindowTitle
		   -- -----------          ---------------
		11556 Spotify              Spotify Free
.CATEGORY System
#>

#Requires -Version 5.1

try {
	Get-Process | Where-Object {$_.mainWindowTitle} | Format-Table ID,ProcessName,MainWindowTitle -AutoSize
	exit 0
} catch {
throw
}
