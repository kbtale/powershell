<#
.SYNOPSIS
	Installs MiniDLNA
.DESCRIPTION
	This PowerShell script installs the MiniDLNA server.
.EXAMPLE
	PS> ./install-mini-dlna.ps1
.CATEGORY Apps
#>

#requires -version 5.1

try {
	$stopWatch = [system.diagnostics.stopwatch]::startNew()

	if (-not($IsLinux)) { throw "Sorry, only Linux installation currently supported" }

	"⏳ (1/4) Installing MiniDLNA from Snap Store..."
	& sudo snap install minidlna-jdstrand

	[int]$elapsed = $stopWatch.Elapsed.TotalSeconds
	"✅ MiniDLNA installed in $($elapsed)s."
	"   Configuration: /var/snap/minidlna-jdstrand/current/minidlna.conf"
	"   Log file: /var/snap/minidlna-jdstrand/current/home/minidlna.log"
	exit 0
} catch {
throw
}
