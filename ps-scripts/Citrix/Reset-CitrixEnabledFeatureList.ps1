<#
.SYNOPSIS
	Citrix: Resets the enabled feature list
.DESCRIPTION
	Resets the list of enabled features for Citrix services to the default state.
.EXAMPLE
	PS> ./Reset-CitrixEnabledFeatureList.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	Reset-ConfigEnabledFeatureList -ErrorAction Stop
	Write-Output "Successfully reset the enabled feature list."
} catch {
	Write-Error $_
	exit 1
}