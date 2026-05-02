<#
.SYNOPSIS
	Citrix: Gets Citrix applications
.DESCRIPTION
	Lists applications registered in the Citrix site.
.PARAMETER Name
	The name of the application (optional).
.EXAMPLE
	PS> ./Get-CitrixApplication.ps1
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

	$apps = Get-BrokerApplication @cmdArgs
	Write-Output $apps
} catch {
	Write-Error $_
	exit 1
}