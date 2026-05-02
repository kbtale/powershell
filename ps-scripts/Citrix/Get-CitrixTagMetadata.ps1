<#
.SYNOPSIS
	Citrix: Gets tag metadata
.DESCRIPTION
	Retrieves metadata associated with a Citrix tag.
.PARAMETER TagName
	The name of the tag.
.EXAMPLE
	PS> ./Get-CitrixTagMetadata.ps1 -TagName "Production"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$TagName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerTagMetadata -Name $TagName -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}