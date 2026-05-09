<#
.SYNOPSIS
	Launches Screen Sketch
.DESCRIPTION
	This script launches the Screen Sketch application.
.EXAMPLE
	PS> ./open-screen-sketch.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	Start-Process ms-screensketch:
	exit 0
} catch {
throw
}
