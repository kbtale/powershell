<#
.SYNOPSIS
	Citrix: Updates a desktop assignment policy rule
.DESCRIPTION
	Updates the properties or status of an existing desktop assignment policy rule.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER Enabled
	Whether the policy rule is enabled.
.EXAMPLE
	PS> ./Set-CitrixDesktopAssignmentPolicyRule.ps1 -Name "HRRule" -Enabled $false
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[bool]$Enabled
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerDesktopAssignmentPolicyRule -Name $Name -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated desktop assignment policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}