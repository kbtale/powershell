<#
.SYNOPSIS
	Starts the Task Manager
.DESCRIPTION
	This script launches the Windows Task Manager application.
.EXAMPLE
	PS> ./open-task-manager.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	Start-Process taskmgr.exe
	exit 0
} catch {
throw
}
