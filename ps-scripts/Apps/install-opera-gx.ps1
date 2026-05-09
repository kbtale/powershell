<#
.SYNOPSIS
	Installs Opera GX
.DESCRIPTION
	This PowerShell script installs Opera GX from Microsoft Store.
.EXAMPLE
	PS> ./install-opera-gx.ps1
.CATEGORY Apps
#>

#requires -version 5.1

try {
	"Installing Opera GX, please wait..."

	& winget install "Opera GX" --source msstore --accept-package-agreements --accept-source-agreements
	if ($lastExitCode -ne 0) { throw "'winget install' failed" }

	"Opera GX installed successfully."
	exit 0
} catch {
throw
}
