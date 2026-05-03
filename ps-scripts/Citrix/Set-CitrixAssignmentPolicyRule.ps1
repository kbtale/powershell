<#
.SYNOPSIS
	Citrix: Updates an assignment policy rule
.DESCRIPTION
	Modifies an existing assignment policy rule's properties.
.PARAMETER Name
	The name of the rule to update.
.PARAMETER Enabled
	Whether the rule is enabled.
.EXAMPLE
	PS> ./Set-CitrixAssignmentPolicyRule.ps1 -Name "PoolAssignment" -Enabled $true
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[bool]$Enabled
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerAssignmentPolicyRule -Name $Name -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated assignment policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}