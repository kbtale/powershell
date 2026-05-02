<#
.SYNOPSIS
	Azure: Updates an Azure virtual machine
.DESCRIPTION
	Updates the state of an Azure virtual machine.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER Name
	The name of the virtual machine.
.EXAMPLE
	PS> ./Update-VM.ps1 -ResourceGroupName "MyResourceGroup" -Name "MyVM"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Az.Compute -ErrorAction Stop
	$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction Stop
	Update-AzVM -ResourceGroupName $ResourceGroupName -VM $vm -ErrorAction Stop
	Write-Output "Successfully updated VM '$Name' in resource group '$ResourceGroupName'."
} catch {
	Write-Error $_
	exit 1
}