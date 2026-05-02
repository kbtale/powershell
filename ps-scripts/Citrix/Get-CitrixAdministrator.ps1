<#
.SYNOPSIS
	Citrix: Gets administrators
.DESCRIPTION
	Lists Citrix administrators in the site.
.PARAMETER Name
	The name of the administrator to filter by (optional).
.EXAMPLE
	PS> ./Get-CitrixAdministrator.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Name
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($Name) { $cmdArgs.Add('Name', $Name) }

	$admins = Get-AdminAdministrator @cmdArgs
	Write-Output $admins
} catch {
	Write-Error $_
	exit 1
}