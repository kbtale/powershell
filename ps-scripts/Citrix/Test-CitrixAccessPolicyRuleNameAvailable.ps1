<#
.SYNOPSIS
	Citrix: Tests access policy rule name availability
.DESCRIPTION
	Checks if a specific name is available for a new access policy rule.
.PARAMETER Name
	The name to check.
.EXAMPLE
	PS> ./Test-CitrixAccessPolicyRuleNameAvailable.ps1 -Name "NewRule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$available = Test-BrokerAccessPolicyRuleNameAvailable -Name $Name -ErrorAction Stop
	if ($available) {
		Write-Output "Access policy rule name '$Name' is available."
	} else {
		Write-Warning "Access policy rule name '$Name' is NOT available."
	}
} catch {
	Write-Error $_
	exit 1
}