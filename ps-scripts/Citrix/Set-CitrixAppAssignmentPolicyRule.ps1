<#
.SYNOPSIS
	Citrix: Updates an application assignment policy rule
.DESCRIPTION
	Updates the properties or status of an existing application assignment policy rule.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER Enabled
	Whether the policy rule is enabled.
.EXAMPLE
	PS> ./Set-CitrixAppAssignmentPolicyRule.ps1 -Name "SalesRule" -Enabled $false
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
	Set-BrokerAppAssignmentPolicyRule -Name $Name -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated application assignment policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}