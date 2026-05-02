<#
.SYNOPSIS
	Citrix: Updates desktop group policy
.DESCRIPTION
	Triggers an update of the policies associated with a Citrix desktop group.
.PARAMETER GroupName
	The name of the desktop group.
.EXAMPLE
	PS> ./Update-CitrixDesktopGroupPolicy.ps1 -GroupName "SalesPool"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$GroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	Set-BrokerDesktopGroupMetadata -Name $GroupName -Name "LastPolicyUpdate" -Value $timestamp -ErrorAction Stop
	Write-Output "Policy update signal sent to desktop group '$GroupName' (Timestamp: $timestamp)."
} catch {
	Write-Error $_
	exit 1
}