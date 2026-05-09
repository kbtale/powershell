<#
.SYNOPSIS
	Clears the DNS cache
.DESCRIPTION
	This PowerShell script empties the DNS client cache of the local computer.
.EXAMPLE
	PS> ./clear-dns-cache.ps1
		✅ DNS cache cleared in 1s.
.CATEGORY Network
#>

#Requires -Version 5.1

try {
	$stopWatch = [system.diagnostics.stopwatch]::startNew()

	Clear-DnsClientCache

	[int]$elapsed = $stopWatch.Elapsed.TotalSeconds
	"✅ DNS cache cleared in $($elapsed)s."
	exit 0
} catch {
throw
}
