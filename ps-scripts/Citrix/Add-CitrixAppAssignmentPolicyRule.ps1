<#
.SYNOPSIS
	Citrix: Adds an application assignment policy rule
.DESCRIPTION
	Creates a new application assignment policy rule in the Citrix site.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER DesktopGroupName
	The name of the associated desktop group.
.EXAMPLE
	PS> ./Add-CitrixAppAssignmentPolicyRule.ps1 -Name "Sales_Apps" -DesktopGroupName "SalesPool"
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
	$rule = New-BrokerAppAssignmentPolicyRule -Name $Name -DesktopGroupName $DesktopGroupName -ErrorAction Stop
	Write-Output $rule
} catch {
	Write-Error $_
	exit 1
}