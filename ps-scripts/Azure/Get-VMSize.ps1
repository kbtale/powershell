<#
.SYNOPSIS
	Azure: Gets current size of an Azure virtual machine
.DESCRIPTION
	Retrieves the current virtual machine size (Hardware Profile) for a specified Azure virtual machine.
.PARAMETER ResourceGroupName
	The name of the resource group containing the virtual machine.
.PARAMETER VMName
	The name of the virtual machine to query.
.EXAMPLE
	PS> ./Get-VMSize.ps1 -ResourceGroupName "myRG" -VMName "myVM"
.CATEGORY Azure
#>

param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$VMName
)

try {
	Import-Module Az.Compute -ErrorAction Stop

	$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -ErrorAction Stop
	$ret = $vm.HardwareProfile.VmSize

	Write-Output $ret
} catch {
	Write-Error $_
	exit 1
}
