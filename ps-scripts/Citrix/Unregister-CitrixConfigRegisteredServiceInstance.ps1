<#
.SYNOPSIS
	Citrix: Unregisters a service instance
.DESCRIPTION
	Removes a service instance registration from the Citrix configuration.
.PARAMETER ServiceInstanceUid
	The unique ID of the service instance to unregister.
.EXAMPLE
	PS> ./Unregister-CitrixConfigRegisteredServiceInstance.ps1 -ServiceInstanceUid "123-abc"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ServiceInstanceUid
)

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	Unregister-ConfigRegisteredServiceInstance -ServiceInstanceUid $ServiceInstanceUid -ErrorAction Stop
	Write-Output "Successfully unregistered service instance '$ServiceInstanceUid'."
} catch {
	Write-Error $_
	exit 1
}