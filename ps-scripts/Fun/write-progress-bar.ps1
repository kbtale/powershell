<#
.SYNOPSIS
	Writes a progress bar
.DESCRIPTION
	This PowerShell script writes a progress bar to the console.
.EXAMPLE
	PS> ./write-progress-bar.ps1
		🕐 I'm working, please wait...
.CATEGORY Fun
#>

#Requires -Version 5.1

$progressBar = @('🕐','🕑','🕒','🕓','🕔','🕕','🕖','🕗','🕘','🕙','🕚','🕛')
    
for ([int]$i = 0; $i -lt 150; $i++) {
	Write-Host "`r$($progressBar[$i % 11]) I'm working, please wait..." -NoNewline
	Start-Sleep -milliseconds 100
}
exit 0
