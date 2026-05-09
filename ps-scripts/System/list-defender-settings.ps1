<#
.SYNOPSIS
	Lists the Windows Defender settings
.DESCRIPTION
	This PowerShell script lists the current settings of Windows Defender Antivirus. NOTE: use 'Set-MpPreference' to change settings (e.g. DisableScanningNetworkFiles)
.EXAMPLE
	PS> ./list-defender-settings.ps1
		AttackSurfaceReductionOnlyExclusions          :
		CheckForSignaturesBeforeRunningScan           : False
.CATEGORY System
#>

#Requires -Version 5.1

try {
	Write-Host " "
	Write-Host "Windows Defender Settings                               Value"
	Write-Host "-------------------------                               -----" -noNewline
	Get-MpPreference
	"NOTE: Documentation at: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/dn455323(v=vs.85)"
	exit 0
} catch {
throw
}
