<#
.SYNOPSIS
	Citrix: Gets desktop entitlement policy rules
.DESCRIPTION
	Lists the desktop entitlement policy rules defined in the Citrix site.
.PARAMETER Name
	The name of the policy rule (optional).
.EXAMPLE
	PS> ./Get-CitrixDesktopEntitlementPolicyRule.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($Name) { $cmdArgs.Add('Name', $Name) }

	$rules = Get-BrokerDesktopEntitlementPolicyRule @cmdArgs
	Write-Output $rules
} catch {
	Write-Error $_
	exit 1
}