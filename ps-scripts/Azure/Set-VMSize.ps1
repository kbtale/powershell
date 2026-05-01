<#
.SYNOPSIS
	Azure: Changes the size of an Azure virtual machine
.DESCRIPTION
	Updates the hardware profile size for a specified Azure virtual machine. 
	IMPORTANT: This script will Stop, Update, and Restart the virtual machine to apply the new size.
.PARAMETER Name
	The name of the virtual machine to resize.
.PARAMETER ResourceGroupName
	The name of the resource group containing the virtual machine.
.PARAMETER Size
	The new size for the virtual machine (e.g., Standard_DS2_v2).
.EXAMPLE
	PS> ./Set-VMSize.ps1 -Name "myVM" -ResourceGroupName "myRG" -Size "Standard_DS2_v2"
.CATEGORY Azure
#>

param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$Size
)

try {
	Import-Module Az.Compute -ErrorAction Stop

	$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction Stop
	$vm.HardwareProfile.VmSize = $Size

	Write-Output "Stopping virtual machine '$Name' to apply new size..."
	Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -Force -ErrorAction Stop

	Write-Output "Updating virtual machine size to '$Size'..."
	Update-AzVM -VM $vm -ResourceGroupName $ResourceGroupName -ErrorAction Stop

	Write-Output "Starting virtual machine '$Name'..."
	Start-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction Stop

	$newSize = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Name).HardwareProfile.VmSize
	Write-Output "Virtual machine size successfully updated to: $newSize"
} catch {
	Write-Error $_
	exit 1
}
