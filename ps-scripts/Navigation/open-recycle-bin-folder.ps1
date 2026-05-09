<#
.SYNOPSIS
	Opens the recycle bin folder
.DESCRIPTION
	This script launches the File Explorer with the user's recycle bin folder.
.EXAMPLE
	PS> ./open-recycle-bin-folder
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	Start shell:recyclebinfolder
	exit 0
} catch {
throw
}
