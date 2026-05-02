<#
.SYNOPSIS
	Citrix: Removes application folder metadata
.DESCRIPTION
	Deletes metadata associated with a Citrix application folder.
.PARAMETER Name
	The path to the folder.
.PARAMETER PropertyName
	The name of the metadata property to remove.
.EXAMPLE
	PS> ./Remove-CitrixApplicationFolderMetadata.ps1 -Name "Finance" -PropertyName "DeptID"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$PropertyName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerApplicationFolderMetadata -Name $Name -Name $PropertyName -ErrorAction Stop
	Write-Output "Successfully removed metadata property '$PropertyName' from folder '$Name'."
} catch {
	Write-Error $_
	exit 1
}