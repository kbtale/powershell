<#
.SYNOPSIS
	Lists the installed software
.DESCRIPTION
	This PowerShell script lists the installed software (except Windows Store apps).
.EXAMPLE
	PS> ./list-installed-software.ps1
		DisplayName                            DisplayVersion                  InstallDate
		-----------                            --------------                  -----------
		CrystalDiskInfo 9.1.1                  9.1.1                           20230718
.CATEGORY System
#>

#Requires -Version 5.1

try {
	Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | select-object DisplayName,DisplayVersion,InstallDate | Format-Table -autoSize
	exit 0
} catch {
throw
}
