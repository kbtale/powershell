<#
.SYNOPSIS
	Installs One Calendar
.DESCRIPTION
	This PowerShell script installs One Calendar from the Microsoft Store.
.EXAMPLE
	PS> ./install-one-calendar.ps1
.CATEGORY Apps
#>

#requires -version 5.1

try {
	"Installing One Calendar, please wait..."

	& winget install "One Calendar" --source msstore --accept-package-agreements --accept-source-agreements
	if ($lastExitCode -ne 0) { throw "'winget install' failed" }

	"One Calendar installed successfully."
	exit 0
} catch {
throw
}
