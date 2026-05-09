<#
.SYNOPSIS
	Launches the Paint 3D app
.DESCRIPTION
	This script launches the Paint 3D application.
.EXAMPLE
	PS> ./open-paint-3d.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	Start-Process ms-paint:
	exit 0
} catch {
throw
}
