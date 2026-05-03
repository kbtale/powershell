<#
.SYNOPSIS
	Citrix: Removes application metadata
.DESCRIPTION
	Deletes metadata associated with a Citrix application.
.PARAMETER Name
	The name of the application.
.PARAMETER PropertyName
	The name of the metadata property to remove.
.EXAMPLE
	PS> ./Remove-CitrixApplicationMetadata.ps1 -Name "Notepad" -PropertyName "LastUsed"
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
	Remove-BrokerApplicationMetadata -Name $Name -Name $PropertyName -ErrorAction Stop
	Write-Output "Successfully removed metadata property '$PropertyName' from application '$Name'."
} catch {
	Write-Error $_
	exit 1
}