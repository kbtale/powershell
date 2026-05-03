<#
.SYNOPSIS
	Citrix: Removes desktop entitlement policy rule metadata
.DESCRIPTION
	Deletes metadata associated with a specific Citrix desktop entitlement policy rule.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER PropertyName
	The name of the metadata property to remove.
.EXAMPLE
	PS> ./Remove-CitrixDesktopEntitlementPolicyRuleMetadata.ps1 -Name "DevRule" -PropertyName "Owner"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$PropertyName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerDesktopEntitlementPolicyRuleMetadata -Name $Name -Name $PropertyName -ErrorAction Stop
	Write-Output "Successfully removed metadata property '$PropertyName' from policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}