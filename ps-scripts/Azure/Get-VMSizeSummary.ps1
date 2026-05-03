<#
.SYNOPSIS
	Azure: Gets a summary of VM sizes
.DESCRIPTION
	Retrieves a summarized list of available VM sizes for a location.
.PARAMETER Location
	The Azure region.
.EXAMPLE
	PS> ./Get-VMSizeSummary.ps1 -Location "EastUS"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Location
)

try {
	Import-Module Az.Compute -ErrorAction Stop
	$sizes = Get-AzVMSize -Location $Location -ErrorAction Stop | Select-Object Name, NumberOfCores, MemoryInMB
	Write-Output $sizes
} catch {
	Write-Error $_
	exit 1
}