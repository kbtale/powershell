<#
.SYNOPSIS
	Azure: Invokes a power command for an Azure virtual machine
.DESCRIPTION
	Executes a power management command (Stop, Start, or Restart) on a specified Azure virtual machine.
.PARAMETER Name
	The name of the virtual machine.
.PARAMETER ResourceGroupName
	The name of the resource group containing the virtual machine.
.PARAMETER Command
	The command to execute: Stop, Start, or Restart.
.EXAMPLE
	PS> ./Invoke-VMCommand.ps1 -Name "myVM" -ResourceGroupName "myRG" -Command "Restart"
.CATEGORY Azure
#>

param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[ValidateSet('Stop', 'Start', 'Restart')]
	[string]$Command
)

try {
	Import-Module Az.Compute -ErrorAction Stop

	[hashtable]$cmdArgs = @{
		'ErrorAction'       = 'Stop'
		'Confirm'           = $false
		'Name'              = $Name
		'ResourceGroupName' = $ResourceGroupName
	}

	switch ($Command) {
		"Stop" {
			$cmdArgs.Add("Force", $true)
			$ret = Stop-AzVM @cmdArgs
		}
		"Start" {
			$ret = Start-AzVM @cmdArgs
		}
		"Restart" {
			$ret = Restart-AzVM @cmdArgs
		}
	}

	Write-Output $ret
} catch {
	Write-Error $_
	exit 1
}
