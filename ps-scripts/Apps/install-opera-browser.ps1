<#
.SYNOPSIS
	Installs Opera Browser
.DESCRIPTION
	This PowerShell script installs Opera Browser from Microsoft Store.
.EXAMPLE
	PS> ./install-opera-browser.ps1
.CATEGORY Apps
#>

#requires -version 5.1

try {
	"Installing Opera Browser, please wait..."

	& winget install "Opera Browser" --source msstore --accept-package-agreements --accept-source-agreements
	if ($lastExitCode -ne 0) { throw "'winget install' failed" }

	"Opera Browser installed successfully."
	exit 0
} catch {
throw
}
