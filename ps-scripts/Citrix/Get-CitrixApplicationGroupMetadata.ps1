<#
.SYNOPSIS
	Citrix: Gets application group metadata
.DESCRIPTION
	Retrieves metadata associated with a specific Citrix application group.
.PARAMETER GroupName
	The name of the application group.
.EXAMPLE
	PS> ./Get-CitrixApplicationGroupMetadata.ps1 -GroupName "Office_Apps"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$GroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerApplicationGroupMetadata -Name $GroupName -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}