<#
.SYNOPSIS
	Citrix: Gets application metadata
.DESCRIPTION
	Retrieves metadata associated with a specific Citrix application.
.PARAMETER ApplicationName
	The name of the application.
.EXAMPLE
	PS> ./Get-CitrixApplicationMetadata.ps1 -ApplicationName "Notepad"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ApplicationName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerApplicationMetadata -Name $ApplicationName -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}