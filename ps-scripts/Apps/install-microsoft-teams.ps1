<#
.SYNOPSIS
	Installs Microsoft Teams
.DESCRIPTION
	This PowerShell script installs Microsoft Teams from the Microsoft Store.
.EXAMPLE
	PS> ./install-microsoft-teams.ps1
.CATEGORY Apps
#>

#requires -version 5.1

try {
	"Installing Microsoft Teams, please wait..."

	& winget install --id Microsoft.Teams --accept-package-agreements --accept-source-agreements
	if ($lastExitCode -ne 0) { throw "'winget install' failed" }

	"Microsoft Teams installed successfully."
	exit 0
} catch {
throw
}
