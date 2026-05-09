<#
.SYNOPSIS
	Launches OBS Studio
.DESCRIPTION
	This script launches the OBS Studio application.
.EXAMPLE
	PS> ./open-obs-studio.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

function TryLaunching { param([string]$Path, [string]$Dir)
	if (test-path "$Path" -pathType leaf) {
		start-process -FilePath "$Path" -WorkingDirectory "$Dir"
		exit 0
	}
}

try {
	TryLaunching "C:\Program Files (x86)\OBS Studio\bin\64bit\obs64.exe" "C:\Program Files (x86)\OBS Studio\bin\64bit\"
	TryLaunching "C:\Program Files\OBS Studio\bin\64bit\obs64.exe" "C:\Program Files\OBS Studio\bin\64bit\"
	exit 0
} catch {
throw
}
