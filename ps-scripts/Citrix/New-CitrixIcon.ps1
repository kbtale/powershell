<#
.SYNOPSIS
	Citrix: Creates a new Citrix icon
.DESCRIPTION
	Creates a new icon resource in the Citrix site.
.PARAMETER EncodedData
	The base64 encoded icon data.
.EXAMPLE
	PS> ./New-CitrixIcon.ps1 -EncodedData "iVBORw0KGgoAAAANSU..."
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$EncodedData
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$icon = New-BrokerIcon -EncodedIconData $EncodedData -ErrorAction Stop
	Write-Output $icon
} catch {
	Write-Error $_
	exit 1
}