<#
.SYNOPSIS
	Azure: Gets resource groups
.DESCRIPTION
	Retrieves information about Azure resource groups in the current subscription.
.PARAMETER Name
	The name of the resource group (optional).
.PARAMETER Location
	The location of the resource group (optional).
.EXAMPLE
	PS> ./Get-ResourceGroup.ps1 -Location "EastUS"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Name,

	[Parameter(Mandatory = $false)]
	[string]$Location
)

try {
	Import-Module Az.Resources -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($Name) { $cmdArgs.Add('Name', $Name) }
	if ($Location) { $cmdArgs.Add('Location', $Location) }

	$rgs = Get-AzResourceGroup @cmdArgs
	Write-Output $rgs
} catch {
	Write-Error $_
	exit 1
}