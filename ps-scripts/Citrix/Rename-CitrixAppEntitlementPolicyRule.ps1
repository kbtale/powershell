<#
.SYNOPSIS
	Citrix: Renames an application entitlement policy rule
.DESCRIPTION
	Changes the name of an existing Citrix application entitlement policy rule.
.PARAMETER Name
	The current name of the policy rule.
.PARAMETER NewName
	The new name for the policy rule.
.EXAMPLE
	PS> ./Rename-CitrixAppEntitlementPolicyRule.ps1 -Name "OldEnt" -NewName "NewEnt"
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
	Rename-BrokerAppEntitlementPolicyRule -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed application entitlement policy rule '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}