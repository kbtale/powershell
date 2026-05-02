<#
.SYNOPSIS
	Citrix: Sets desktop assignment policy rule metadata
.DESCRIPTION
	Updates or adds metadata associated with a desktop assignment policy rule.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixDesktopAssignmentPolicyRuleMetadata.ps1 -Name "HRRule" -Map @{ 'Site' = 'Primary' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerDesktopAssignmentPolicyRuleMetadata -Name $Name -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}