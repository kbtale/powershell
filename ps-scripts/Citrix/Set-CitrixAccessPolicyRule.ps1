<#
.SYNOPSIS
	Citrix: Updates an access policy rule
.DESCRIPTION
	Modifies an existing access policy rule's properties.
.PARAMETER Name
	The name of the rule to update.
.PARAMETER Enabled
	Whether the rule is enabled.
.EXAMPLE
	PS> ./Set-CitrixAccessPolicyRule.ps1 -Name "RemoteAccess" -Enabled $false
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
	Set-BrokerAccessPolicyRule -Name $Name -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated access policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}