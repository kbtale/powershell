<#
.SYNOPSIS
	Citrix: Moves an application folder
.DESCRIPTION
	Moves a Citrix application folder to a new parent location.
.PARAMETER FolderPath
	The current path of the folder.
.PARAMETER DestinationParent
	The path to the new parent folder.
.EXAMPLE
	PS> ./Move-CitrixApplicationFolder.ps1 -FolderPath "Sales\Docs" -DestinationParent "Archive"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$FolderPath,

	[Parameter(Mandatory = $true)]
	[string]$DestinationParent
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerApplicationFolder -Name $FolderPath -ParentAdminFolderName $DestinationParent -ErrorAction Stop
	Write-Output "Successfully moved application folder '$FolderPath' to '$DestinationParent'."
} catch {
	Write-Error $_
	exit 1
}