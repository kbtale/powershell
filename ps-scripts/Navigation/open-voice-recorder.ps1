<#
.SYNOPSIS
	Launches the Voice Recorder app
.DESCRIPTION
	This PowerShell script launches the Windows Voice Recorder application.
.EXAMPLE
	PS> ./open-voice-recorder.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	Start-Process explorer.exe shell:appsFolder\Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe!App
        exit 0
} catch {
throw
}
