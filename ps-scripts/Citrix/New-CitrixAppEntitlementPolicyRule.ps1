<#
.SYNOPSIS
	Citrix: Creates a new application entitlement policy rule
.DESCRIPTION
	Creates a new application entitlement policy rule for a desktop group.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER DesktopGroupName
	The name of the desktop group.
.EXAMPLE
	PS> ./New-CitrixAppEntitlementPolicyRule.ps1 -Name "Finance_Rule" -DesktopGroupName "FinancePool"
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
	$rule = New-BrokerAppEntitlementPolicyRule -Name $Name -DesktopGroupName $DesktopGroupName -ErrorAction Stop
	Write-Output $rule
} catch {
	Write-Error $_
	exit 1
}