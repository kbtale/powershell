<#
.SYNOPSIS
	Uninstalls the new Outlook
.DESCRIPTION
	This PowerShell script uninstalls the new Outlook for Windows application.
.EXAMPLE
	PS> ./uninstall-new-outlook.ps1
.CATEGORY Utilities
#>

#Requires -Version 5.1

try {
	"⏳ Uninstalling new Outlook for Windows..."

	Remove-AppxProvisionedPackage -AllUsers -Online -PackageName (Get-AppxPackage Microsoft.OutlookForWindows).PackageFullName
	
	"✅ New Outlook for Windows has been removed."
	exit 0
} catch {
throw
}
