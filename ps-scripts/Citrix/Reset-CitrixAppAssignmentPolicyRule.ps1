<#
.SYNOPSIS
	Citrix: Resets an application assignment policy rule
.DESCRIPTION
	Resets the properties of a Citrix application assignment policy rule to their default values.
.PARAMETER Name
	The name of the policy rule.
.EXAMPLE
	PS> ./Reset-CitrixAppAssignmentPolicyRule.ps1 -Name "SalesRule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	# Resetting usually involves re-setting to known defaults.
	Set-BrokerAppAssignmentPolicyRule -Name $Name -Enabled $true -ErrorAction Stop
	Write-Output "Successfully reset application assignment policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}