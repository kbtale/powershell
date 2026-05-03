<#
.SYNOPSIS
	Citrix: Removes an application assignment policy rule
.DESCRIPTION
	Deletes an existing application assignment policy rule from the Citrix site.
.PARAMETER Name
	The name of the policy rule to remove.
.EXAMPLE
	PS> ./Remove-CitrixAppAssignmentPolicyRule.ps1 -Name "Old_Rule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerAppAssignmentPolicyRule -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed application assignment policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}