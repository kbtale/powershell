<#
.SYNOPSIS
	Citrix: Renames an application assignment policy rule
.DESCRIPTION
	Changes the name of an existing Citrix application assignment policy rule.
.PARAMETER Name
	The current name of the policy rule.
.PARAMETER NewName
	The new name for the policy rule.
.EXAMPLE
	PS> ./Rename-CitrixAppAssignmentPolicyRule.ps1 -Name "OldRule" -NewName "NewRule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$NewName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Rename-BrokerAppAssignmentPolicyRule -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed application assignment policy rule '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}