<#
.SYNOPSIS
	Launches Screen Clip
.DESCRIPTION
	This script launches the Screen Clip application.
.EXAMPLE
	PS> ./open-screen-clip.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	Start-Process ms-screenclip:
	exit 0
} catch {
throw
}
