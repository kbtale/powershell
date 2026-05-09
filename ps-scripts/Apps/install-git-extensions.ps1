<#
.SYNOPSIS
	Installs Git Extensions
.DESCRIPTION
	This PowerShell script installs Git Extensions.
.EXAMPLE
	PS> ./install-git-extensions.ps1
.CATEGORY Apps
#>

#requires -version 5.1

try {
	"Installing Git Extensions, please wait..."

	& winget install --id GitExtensionsTeam.GitExtensions --accept-package-agreements --accept-source-agreements
	if ($lastExitCode -ne 0) { throw "'winget install' failed" }

	"Git Extensions installed successfully."
	exit 0
} catch {
throw
}
