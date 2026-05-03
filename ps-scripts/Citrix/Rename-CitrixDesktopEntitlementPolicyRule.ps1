<#
.SYNOPSIS
	Citrix: Renames a desktop entitlement policy rule
.DESCRIPTION
	Changes the name of an existing Citrix desktop entitlement policy rule.
.PARAMETER Name
	The current name of the policy rule.
.PARAMETER NewName
	The new name for the policy rule.
.EXAMPLE
	PS> ./Rename-CitrixDesktopEntitlementPolicyRule.ps1 -Name "OldEnt" -NewName "NewEnt"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$NewName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Rename-BrokerDesktopEntitlementPolicyRule -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed desktop entitlement policy rule '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}