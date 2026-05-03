<#
.SYNOPSIS
	Citrix: Updates a Citrix icon
.DESCRIPTION
	Updates the data of an existing Citrix icon.
.PARAMETER Id
	The unique ID of the icon.
.PARAMETER EncodedData
	The new base64 encoded icon data.
.EXAMPLE
	PS> ./Update-CitrixIcon.ps1 -Id 1 -EncodedData "iVBORw0KGgo..."
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[int]$Id,

	[Parameter(Mandatory = $true)]
	[string]$EncodedData
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$newIcon = New-BrokerIcon -EncodedIconData $EncodedData -ErrorAction Stop
	$newUid = $newIcon.Uid
	$appGroups = Get-BrokerApplicationGroup -Filter "IconUid -eq $Id" -ErrorAction SilentlyContinue
	foreach ($ag in $appGroups) {
		Set-BrokerApplicationGroup -InputObject $ag -IconUid $newUid -ErrorAction Stop
	}
	$apps = Get-BrokerApplication -Filter "IconUid -eq $Id" -ErrorAction SilentlyContinue
	foreach ($app in $apps) {
		Set-BrokerApplication -InputObject $app -IconUid $newUid -ErrorAction Stop
	}
	try {
		Remove-BrokerIcon -Uid $Id -ErrorAction SilentlyContinue
	} catch {}
	Write-Output $newIcon
} catch {
	Write-Error $_
	exit 1
}