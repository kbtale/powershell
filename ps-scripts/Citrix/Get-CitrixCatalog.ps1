<#
.SYNOPSIS
	Citrix: Gets Citrix catalogs
.DESCRIPTION
	Lists machine catalogs defined in the Citrix site.
.PARAMETER Name
	The name of the catalog (optional).
.EXAMPLE
	PS> ./Get-CitrixCatalog.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($Name) { $cmdArgs.Add('Name', $Name) }

	$catalogs = Get-BrokerCatalog @cmdArgs
	Write-Output $catalogs
} catch {
	Write-Error $_
	exit 1
}