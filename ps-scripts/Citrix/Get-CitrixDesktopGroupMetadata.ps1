<#
.SYNOPSIS
	Citrix: Gets desktop group metadata
.DESCRIPTION
	Retrieves metadata associated with a specific Citrix desktop group.
.PARAMETER GroupName
	The name of the desktop group.
.EXAMPLE
	PS> ./Get-CitrixDesktopGroupMetadata.ps1 -GroupName "SalesPool"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$GroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerDesktopGroupMetadata -Name $GroupName -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}