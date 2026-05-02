<#
.SYNOPSIS
	Citrix: Gets Citrix tags
.DESCRIPTION
	Lists tags defined in the Citrix site.
.PARAMETER Name
	The name of the tag (optional).
.EXAMPLE
	PS> ./Get-CitrixTag.ps1
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

	$tags = Get-BrokerTag @cmdArgs
	Write-Output $tags
} catch {
	Write-Error $_
	exit 1
}