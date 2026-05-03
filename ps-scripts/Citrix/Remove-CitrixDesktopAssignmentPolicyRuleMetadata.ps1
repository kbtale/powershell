<#
.SYNOPSIS
	Citrix: Removes desktop assignment policy rule metadata
.DESCRIPTION
	Deletes metadata associated with a specific Citrix desktop assignment policy rule.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER PropertyName
	The name of the metadata property to remove.
.EXAMPLE
	PS> ./Remove-CitrixDesktopAssignmentPolicyRuleMetadata.ps1 -Name "HRRule" -PropertyName "DeptID"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$PropertyName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerDesktopAssignmentPolicyRuleMetadata -Name $Name -Name $PropertyName -ErrorAction Stop
	Write-Output "Successfully removed metadata property '$PropertyName' from policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}