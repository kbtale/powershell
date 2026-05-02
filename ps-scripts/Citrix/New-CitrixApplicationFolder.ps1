<#
.SYNOPSIS
	Citrix: Creates a new application folder
.DESCRIPTION
	Creates a new administrative folder for organizing Citrix applications.
.PARAMETER FolderName
	The name for the new folder.
.PARAMETER ParentFolder
	The path to the parent folder (optional).
.EXAMPLE
	PS> ./New-CitrixApplicationFolder.ps1 -FolderName "Finance"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$FolderName,

	[Parameter(Mandatory = $false)]
	[string]$ParentFolder
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'Name' = $FolderName; 'ErrorAction' = 'Stop' }
	if ($ParentFolder) { $cmdArgs.Add('ParentAdminFolder', $ParentFolder) }

	$folder = New-BrokerApplicationFolder @cmdArgs
	Write-Output $folder
} catch {
	Write-Error $_
	exit 1
}