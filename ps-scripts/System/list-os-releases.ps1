<#
.SYNOPSIS
	Lists OS releases and download URL
.DESCRIPTION
	This PowerShell script lists OS releases and download URL.
.EXAMPLE
	PS> ./list-os-releases.ps1
.CATEGORY System
#>

#Requires -Version 5.1

try {
	write-progress "Reading OS_IPFS_hashes.csv ..."

	$PathToRepo = "$PSScriptRoot/.."
	$PathToCsvFile = "$PathToRepo/data/os-release.csv"
	invoke-webRequest -URI "https://fleschutz.droppages.com/downloads/OS_IPFS_hashes.csv" -outFile "$PathToCsvFile"

	$Table = import-csv "$PathToCsvFile"
	remove-item -path "$PathToCsvFile"

	write-output "Operating System Releases"
	write-output "========================="
	foreach ($Row in $Table) {
		write-output "* $($Row.Path.substring(3)) -> ipfs://$($Row.IPFS)"
	}
	exit 0
} catch {
throw
}
