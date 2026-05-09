<#
.SYNOPSIS
	Hibernates the computer
.DESCRIPTION
	This PowerShell script hibernates the local computer immediately.
.EXAMPLE
	PS> ./hibernate.ps1
		It's 5:04 PM, going to sleep now... 😴💤
.CATEGORY System
#>

#Requires -Version 5.1

try {
	[system.threading.thread]::currentThread.currentCulture = [system.globalization.cultureInfo]"en-US"
	$CurrentTime = $((Get-Date).ToShortTimeString())
	Write-Host "It's $CurrentTime, going to sleep now... 😴💤"
	Start-Sleep -milliseconds 500
	& rundll32.exe powrprof.dll,SetSuspendState 1,1,0
	exit 0
} catch {
throw
}
