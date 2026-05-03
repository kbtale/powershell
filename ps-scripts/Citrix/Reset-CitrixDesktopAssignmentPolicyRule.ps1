<#
.SYNOPSIS
	Citrix: Resets a desktop assignment policy rule
.DESCRIPTION
	Resets the properties of a Citrix desktop assignment policy rule to their default values.
.PARAMETER Name
	The name of the policy rule.
.EXAMPLE
	PS> ./Reset-CitrixDesktopAssignmentPolicyRule.ps1 -Name "HRRule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerDesktopAssignmentPolicyRule -Name $Name -Enabled $true -ErrorAction Stop
	Write-Output "Successfully reset desktop assignment policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}