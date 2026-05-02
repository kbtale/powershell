<#
.SYNOPSIS
	Citrix: Gets service added capabilities
.DESCRIPTION
	Retrieves the capabilities added to a specific Citrix service.
.PARAMETER ServiceType
	The type of Citrix service.
.EXAMPLE
	PS> ./Get-CitrixServiceAddedCapability.ps1 -ServiceType Broker
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ServiceType
)

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	$caps = Get-ConfigServiceAddedCapability -ServiceType $ServiceType -ErrorAction Stop
	Write-Output $caps
} catch {
	Write-Error $_
	exit 1
}