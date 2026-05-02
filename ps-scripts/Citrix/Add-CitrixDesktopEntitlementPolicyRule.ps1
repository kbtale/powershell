<#
.SYNOPSIS
	Citrix: Adds a desktop entitlement policy rule
.DESCRIPTION
	Creates a new desktop entitlement policy rule in the Citrix site.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER DesktopGroupName
	The name of the associated desktop group.
.EXAMPLE
	PS> ./Add-CitrixDesktopEntitlementPolicyRule.ps1 -Name "Dev_Entitlement" -DesktopGroupName "DevPool"
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