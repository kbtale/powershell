<#
.SYNOPSIS
	Citrix: Updates a desktop entitlement policy rule
.DESCRIPTION
	Updates the properties or status of an existing desktop entitlement policy rule.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER Enabled
	Whether the policy rule is enabled.
.EXAMPLE
	PS> ./Set-CitrixDesktopEntitlementPolicyRule.ps1 -Name "DevRule" -Enabled $true
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
	Set-BrokerDesktopEntitlementPolicyRule -Name $Name -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated desktop entitlement policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}