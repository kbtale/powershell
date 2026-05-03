<#
.SYNOPSIS
	Citrix: Creates a new desktop entitlement policy rule
.DESCRIPTION
	Creates a new desktop entitlement policy rule for a desktop group.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER DesktopGroupName
	The name of the desktop group.
.EXAMPLE
	PS> ./New-CitrixDesktopEntitlementPolicyRule.ps1 -Name "Dev_Rule" -DesktopGroupName "DevPool"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$DesktopGroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$rule = New-BrokerDesktopEntitlementPolicyRule -Name $Name -DesktopGroupName $DesktopGroupName -ErrorAction Stop
	Write-Output $rule
} catch {
	Write-Error $_
	exit 1
}