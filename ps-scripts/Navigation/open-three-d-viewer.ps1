<#
.SYNOPSIS
	Launches the 3D-Viewer app
.DESCRIPTION
	This script launches the 3D-Viewer application.
.EXAMPLE
	PS> ./open-three-d-viewer.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

Start-Process com.microsoft.3dviewer:
exit 0
