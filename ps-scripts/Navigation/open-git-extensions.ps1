<#
.SYNOPSIS
	Launches Git Extensions
.DESCRIPTION
	This PowerShell script launches the Git Extensions application.
.EXAMPLE
	PS> ./open-git-extensions
.CATEGORY Navigation
#>

#requires -version 5.1

function TryToExec { param($Folder, $Binary)
	if (test-path "$Folder/$Binary" -pathType leaf) {
		start-process "$Folder/$Binary" -WorkingDirectory "$Folder"
		exit 0
	}
}

try {
	TryToExec "C:\Program Files (x86)\GitExtensions" "GitExtensions.exe"
	TryToExec "C:\Program Files\GitExtensions" "GitExtensions.exe"
	& "$PSScriptRoot/speak-english.ps1" "Sorry, can't find Git Extensions."
	exit 1
} catch {
throw
}
