<#
.SYNOPSIS
	Citrix: Renames a desktop assignment policy rule
.DESCRIPTION
	Changes the name of an existing Citrix desktop assignment policy rule.
.PARAMETER Name
	The current name of the policy rule.
.PARAMETER NewName
	The new name for the policy rule.
.EXAMPLE
	PS> ./Rename-CitrixDesktopAssignmentPolicyRule.ps1 -Name "OldDsk" -NewName "NewDsk"
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
	Rename-BrokerDesktopAssignmentPolicyRule -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed desktop assignment policy rule '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}