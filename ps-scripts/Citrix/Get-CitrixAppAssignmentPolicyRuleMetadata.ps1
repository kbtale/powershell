<#
.SYNOPSIS
	Citrix: Gets application assignment policy rule metadata
.DESCRIPTION
	Retrieves metadata associated with a specific application assignment policy rule.
.PARAMETER Name
	The name of the policy rule.
.EXAMPLE
	PS> ./Get-CitrixAppAssignmentPolicyRuleMetadata.ps1 -Name "SalesRule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerAppAssignmentPolicyRuleMetadata -Name $Name -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}