<#
.SYNOPSIS
	Citrix: Removes a desktop assignment policy rule
.DESCRIPTION
	Deletes an existing desktop assignment policy rule from the Citrix site.
.PARAMETER Name
	The name of the policy rule to remove.
.EXAMPLE
	PS> ./Remove-CitrixDesktopAssignmentPolicyRule.ps1 -Name "HR_Assignment"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerDesktopAssignmentPolicyRule -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed desktop assignment policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}