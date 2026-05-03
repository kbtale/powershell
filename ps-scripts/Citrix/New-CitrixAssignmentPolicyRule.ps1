<#
.SYNOPSIS
	Citrix: Creates an assignment policy rule
.DESCRIPTION
	Adds a new assignment policy rule to the Citrix site.
.PARAMETER Name
	The name of the new assignment policy rule.
.PARAMETER DesktopGroupUid
	The UID of the desktop group to associate with the rule.
.EXAMPLE
	PS> ./New-CitrixAssignmentPolicyRule.ps1 -Name "PoolAssignment" -DesktopGroupUid 1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[int]$DesktopGroupUid
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$rule = New-BrokerAssignmentPolicyRule -Name $Name -DesktopGroupUid $DesktopGroupUid -ErrorAction Stop
	Write-Output $rule
} catch {
	Write-Error $_
	exit 1
}