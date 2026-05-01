<#
.SYNOPSIS
	Azure: Gets properties of Azure virtual machines
.DESCRIPTION
	Retrieves property information for one or more Azure virtual machines, with support for filtering by name, resource group, or location.
.PARAMETER Name
	The name of the virtual machine to retrieve.
.PARAMETER ResourceGroupName
	The name of the resource group containing the virtual machine.
.PARAMETER Location
	The Azure location to filter the virtual machines.
.PARAMETER Properties
	List of properties to include in the output. Use * for all properties.
.EXAMPLE
	PS> ./Get-VM.ps1 -Location "EastUS"
.CATEGORY Azure
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = 'ResourceGroup')]
	[string]$Name,

	[Parameter(Mandatory = $true, ParameterSetName = 'ResourceGroup')]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true, ParameterSetName = 'Location')]
	[string]$Location,

	[Parameter(ParameterSetName = 'All')]
	[Parameter(ParameterSetName = 'Location')]
	[Parameter(ParameterSetName = 'ResourceGroup')]
	[ValidateSet('*', 'Name', 'Location', 'ResourceGroupName', 'Tags', 'VmId', 'StatusCode', 'ID')]
	[string[]]$Properties = @('Name', 'Location', 'ResourceGroupName', 'Tags', 'VmId', 'StatusCode', 'ID')
)

try {
	Import-Module Az.Compute -ErrorAction Stop

	if ($Properties -contains '*') {
		$Properties = @('*')
	}

	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }

	if ($PSCmdlet.ParameterSetName -eq 'ResourceGroup') {
		$cmdArgs.Add('Name', $Name)
		$cmdArgs.Add('ResourceGroupName', $ResourceGroupName)
	} elseif ($PSCmdlet.ParameterSetName -eq 'Location') {
		$cmdArgs.Add('Location', $Location)
	}

	$ret = Get-AzVM @cmdArgs | Select-Object $Properties
	Write-Output $ret
} catch {
	Write-Error $_
	exit 1
}
