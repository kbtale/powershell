<#
.SYNOPSIS
	Citrix: Tests Citrix access
.DESCRIPTION
	Validates whether the current user has administrative access to the Citrix site.
.EXAMPLE
	PS> ./Test-CitrixAccess.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$access = Test-AdminAccess -ErrorAction Stop
	if ($access) {
		Write-Output "Administrative access verified."
	} else {
		Write-Warning "Administrative access denied."
	}
} catch {
	Write-Error $_
	exit 1
}