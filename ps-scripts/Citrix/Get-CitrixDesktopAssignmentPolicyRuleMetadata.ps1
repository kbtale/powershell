<#
.SYNOPSIS
	Citrix: Gets desktop assignment policy rule metadata
.DESCRIPTION
	Retrieves metadata associated with a specific desktop assignment policy rule.
.PARAMETER Name
	The name of the policy rule.
.EXAMPLE
	PS> ./Get-CitrixDesktopAssignmentPolicyRuleMetadata.ps1 -Name "HRRule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerDesktopAssignmentPolicyRuleMetadata -Name $Name -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}