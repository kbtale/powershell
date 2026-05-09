<#
.SYNOPSIS
	Closes the OneCalendar app
.DESCRIPTION
	This PowerShell script closes the OneCalendar application gracefully.
.EXAMPLE
	PS> ./close-one-calendar.ps1
.CATEGORY System
#>

#Requires -Version 5.1

TaskKill /f /im CalendarApp.Gui.Win10.exe
if ($lastExitCode -ne 0) {
	& "$PSScriptRoot/speak-english.ps1" "Sorry, OneCalendar isn't running."
	exit 1
}
exit 0
