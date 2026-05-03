<#
.SYNOPSIS
	Citrix: Resets service group membership
.DESCRIPTION
	Resets the service group membership configuration in the Citrix site.
.EXAMPLE
	PS> ./Reset-CitrixServiceGroupMembership.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	Reset-ConfigServiceGroupMembership -ErrorAction Stop
	Write-Output "Successfully reset service group membership."
} catch {
	Write-Error $_
	exit 1
}