<#
.SYNOPSIS
	Azure: Gets a report of VM sizes
.DESCRIPTION
	Retrieves a list of available virtual machine sizes for a specific Azure region.
.PARAMETER Location
	The Azure region to check.
.EXAMPLE
	PS> ./Get-VMSizeReport.ps1 -Location "EastUS"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Location
)

try {
	Import-Module Az.Compute -ErrorAction Stop
	$sizes = Get-AzVMSize -Location $Location -ErrorAction Stop | Select-Object Name, NumberOfCores, MemoryInMB, MaxDataDiskCount
	Write-Output $sizes
} catch {
	Write-Error $_
	exit 1
}