<#
.SYNOPSIS
	Citrix: Gets role configuration
.DESCRIPTION
	Retrieves the configuration details for Citrix administrator roles.
.PARAMETER RoleName
	The name of the role (optional).
.EXAMPLE
	PS> ./Get-CitrixRoleConfiguration.ps1 -RoleName "HelpDesk"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$RoleName
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($RoleName) { $cmdArgs.Add('Role', $RoleName) }

	$config = Get-AdminRoleConfiguration @cmdArgs
	Write-Output $config
} catch {
	Write-Error $_
	exit 1
}