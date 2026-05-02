<#
.SYNOPSIS
	Citrix: Removes an assignment policy rule
.DESCRIPTION
	Deletes an existing assignment policy rule from the Citrix site.
.PARAMETER Name
	The name of the rule to remove.
.EXAMPLE
	PS> ./Remove-CitrixAssignmentPolicyRule.ps1 -Name "PoolAssignment"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerAssignmentPolicyRule -Name $Name -ErrorAction Stop
	Write-Output "Successfully removed assignment policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}