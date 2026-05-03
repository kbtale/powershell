<#
.SYNOPSIS
	Citrix: Adds a Citrix icon
.DESCRIPTION
	Registers a new icon in the Citrix site from a file or byte array.
.PARAMETER ImagePath
	The local path to the icon image file.
.EXAMPLE
	PS> ./Add-CitrixIcon.ps1 -ImagePath "C:\Icons\App.png"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ImagePath
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$iconData = [System.IO.File]::ReadAllBytes($ImagePath)
	$icon = New-BrokerIcon -EncodedIconData ([System.Convert]::ToBase64String($iconData)) -ErrorAction Stop
	Write-Output $icon
} catch {
	Write-Error $_
	exit 1
}