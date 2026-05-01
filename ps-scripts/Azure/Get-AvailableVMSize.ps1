<#
.SYNOPSIS
	Azure: Gets available virtual machine sizes
.DESCRIPTION
	Retrieves the list of available virtual machine sizes for a specific location or for resizing a specific virtual machine.
.PARAMETER ResourceGroupName
	The name of the resource group containing the virtual machine.
.PARAMETER VMName
	The name of the virtual machine to get available sizes for.
.PARAMETER Location
	The Azure location to query for available sizes.
.EXAMPLE
	PS> ./Get-AvailableVMSize.ps1 -Location "EastUS"
.CATEGORY Azure
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "ResourceGroup")]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true, ParameterSetName = "ResourceGroup")]
	[string]$VMName,

	[Parameter(Mandatory = $true, ParameterSetName = "Location")]
	[string]$Location
)

try {
	Import-Module Az.Compute -ErrorAction Stop

	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }

	if ($PSCmdlet.ParameterSetName -eq "ResourceGroup") {
		$cmdArgs.Add('ResourceGroupName', $ResourceGroupName)
		$cmdArgs.Add('VMName', $VMName)
	} else {
		$cmdArgs.Add('Location', $Location)
	}

	$ret = Get-AzVMSize @cmdArgs | Select-Object *
	Write-Output $ret
} catch {
	Write-Error $_
	exit 1
}
