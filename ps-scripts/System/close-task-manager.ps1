<#
.SYNOPSIS
	Closes the Task Manager
.DESCRIPTION
	This PowerShell script closes the Task Manager application gracefully.
.EXAMPLE
	PS> ./close-task-manager.ps1
.CATEGORY System
#>

#Requires -Version 5.1

tskill taskmgr
exit 0
