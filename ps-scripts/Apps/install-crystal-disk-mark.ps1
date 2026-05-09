<#
.SYNOPSIS
	Installs CrystalDiskMark
.DESCRIPTION
	This PowerShell script installs CrystalDiskMark from the Microsoft Store.
.EXAMPLE
	PS> ./install-crystal-disk-mark.ps1
.CATEGORY Apps
#>

#requires -version 5.1

try {
	"Installing CrystalDiskMark, please wait..."

	& winget install "CrystalDiskMark Shizuku Edition" --source msstore --accept-package-agreements --accept-source-agreements
	if ($lastExitCode -ne 0) { throw "'winget install' failed" }

	"CrystalDiskMark installed successfully."
	exit 0
} catch {
throw
}
