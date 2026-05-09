<#
.SYNOPSIS
	Plays an ASCII video
.DESCRIPTION
	This PowerShell script launches the Web browser with YouTube playing Rick Astley.
.EXAMPLE
	PS> ./play-ascii-video.ps1
.CATEGORY Fun
#>

#Requires -Version 5.1

if ($IsLinux -or $IsMacOS) {
	& curl ascii.live/forrest
} else {
	& curl.exe ascii.live/forrest
}
exit 0
