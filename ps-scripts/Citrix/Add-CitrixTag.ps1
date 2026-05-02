<#
.SYNOPSIS
	Citrix: Adds a tag to a resource
.DESCRIPTION
	Assigns a tag to a Citrix resource (e.g. machine, application).
.PARAMETER TagName
	The name of the tag.
.PARAMETER ResourceName
	The name of the resource to tag.
.EXAMPLE
	PS> ./Add-CitrixTag.ps1 -TagName "Production" -ResourceName "AppServer01"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$TagName,

	[Parameter(Mandatory = $true)]
	[string]$ResourceName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Add-BrokerTag -Name $TagName -MachineName $ResourceName -ErrorAction Stop
	Write-Output "Successfully added tag '$TagName' to '$ResourceName'."
} catch {
	Write-Error $_
	exit 1
}