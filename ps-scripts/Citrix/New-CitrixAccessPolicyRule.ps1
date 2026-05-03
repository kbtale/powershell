<#
.SYNOPSIS
	Citrix: Creates an access policy rule
.DESCRIPTION
	Adds a new access policy rule to the Citrix site.
.PARAMETER Name
	The name of the new access policy rule.
.PARAMETER DesktopGroupUid
	The UID of the desktop group to associate with the rule.
.PARAMETER AllowedUsers
	The users allowed by this rule.
.EXAMPLE
	PS> ./New-CitrixAccessPolicyRule.ps1 -Name "RemoteAccess" -DesktopGroupUid 1 -AllowedUsers "CONTOSO\Sales"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[int]$DesktopGroupUid,

	[Parameter(Mandatory = $true)]
	[string]$AllowedUsers
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$rule = New-BrokerAccessPolicyRule -Name $Name -DesktopGroupUid $DesktopGroupUid -AllowedUsers $AllowedUsers -ErrorAction Stop
	Write-Output $rule
} catch {
	Write-Error $_
	exit 1
}