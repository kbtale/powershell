<#
.SYNOPSIS
	Citrix: Gets application folders
.DESCRIPTION
	Lists the application folders defined in the Citrix site.
.PARAMETER FolderPath
	The path to the folder (optional).
.EXAMPLE
	PS> ./Get-CitrixApplicationFolder.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$FolderPath
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($FolderPath) { $cmdArgs.Add('Name', $FolderPath) }

	$folders = Get-BrokerApplicationFolder @cmdArgs
	Write-Output $folders
} catch {
	Write-Error $_
	exit 1
}