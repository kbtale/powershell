<#
.SYNOPSIS
	Installs Visual Studio Code
.DESCRIPTION
	This PowerShell script installs Visual Studio Code.
.EXAMPLE
	PS> ./install-visual-studio-code.ps1
.CATEGORY Apps
#>

#requires -version 5.1

try {
	"Installing Visual Studio Code, please wait..."

	& winget install --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements
	if ($lastExitCode -ne 0) { throw "'winget install' failed" }

	"Visual Studio Code installed successfully."
	exit 0
} catch {
throw
}
