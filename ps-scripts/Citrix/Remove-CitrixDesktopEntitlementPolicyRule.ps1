<#
.SYNOPSIS
	Citrix: Removes a desktop entitlement policy rule
.DESCRIPTION
	Deletes an existing desktop entitlement policy rule from the Citrix site.
.PARAMETER Name
	The name of the policy rule to remove.
.EXAMPLE
	PS> ./Remove-CitrixDesktopEntitlementPolicyRule.ps1 -Name "Dev_Entitlement"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerDesktopEntitlementPolicyRule -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed desktop entitlement policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}