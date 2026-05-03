<#
.SYNOPSIS
	Citrix: Removes an access policy rule
.DESCRIPTION
	Deletes an existing access policy rule from the Citrix site.
.PARAMETER Name
	The name of the rule to remove.
.EXAMPLE
	PS> ./Remove-CitrixAccessPolicyRule.ps1 -Name "RemoteAccess"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerAccessPolicyRule -Name $Name -ErrorAction Stop
	Write-Output "Successfully removed access policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}