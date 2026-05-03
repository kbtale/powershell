<#
.SYNOPSIS
	Citrix: Gets application folder metadata
.DESCRIPTION
	Retrieves metadata associated with a Citrix application folder.
.PARAMETER FolderPath
	The path to the application folder.
.EXAMPLE
	PS> ./Get-CitrixApplicationFolderMetadata.ps1 -FolderPath "Finance\Reports"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$FolderPath
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerApplicationFolderMetadata -Name $FolderPath -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}