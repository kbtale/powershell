<#
.SYNOPSIS
	Installs Microsoft Powertoys
.DESCRIPTION
	This PowerShell script installs the Microsoft Powertoys.
.EXAMPLE
	PS> ./install-power-toys.ps1
.CATEGORY Apps
#>

#requires -version 5.1

try {
	"Installing Microsoft Powertoys, please wait..."

	& winget install Microsoft.Powertoys --accept-package-agreements --accept-source-agreements
	if ($lastExitCode -ne 0) { throw "'winget install' failed" }

	"Microsoft Powertoys installed successfully."
	exit 0
} catch {
throw
}
