#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Invokes a failover operation for a virtual machine

.DESCRIPTION
    Manages the failover lifecycle for a Microsoft Hyper-V Replica virtual machine. Supports starting (as test or planned), stopping, and completing failovers.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER Action
    Specifies the failover action to perform (Start, Stop, Complete).

.PARAMETER RecoverySnapshot
    Optional. Specifies a specific recovery snapshot (checkpoint) to use for the failover.

.PARAMETER Test
    If set, starts the failover as a test, creating a temporary test virtual machine.

.PARAMETER Planned
    If set, performs a planned failover (requires the VM to be shut down and primary to be reachable).

.EXAMPLE
    PS> ./Invoke-HyperVVMFailover.ps1 -Name "ERP-Srv" -Action Start -Test

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Start', 'Stop', 'Complete')]
    [string]$Action,

    [string]$RecoverySnapshot,

    [switch]$Test,

    [switch]$Planned
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $vm = Get-VM @params | Where-Object { $_.Name -eq $Name -or $_.Id -eq $Name }

        if (-not $vm) {
            throw "Virtual machine '$Name' not found on '$ComputerName'."
        }

        switch ($Action) {
            'Start' {
                $failoverParams = @{ 'VM' = $vm; 'ErrorAction' = 'Stop' }
                if ($Test) { $failoverParams.Add('AsTest', $true) }
                if ($Planned) { $failoverParams.Add('Prepare', $true) }
                
                if ($RecoverySnapshot) {
                    $snapshot = Get-VMSnapshot -VM $vm -Name $RecoverySnapshot -ErrorAction Stop
                    Start-VMFailover -VMSnapshot $snapshot @failoverParams
                }
                else {
                    Start-VMFailover @failoverParams
                }
            }
            'Stop' {
                Stop-VMFailover -VM $vm -ErrorAction Stop
            }
            'Complete' {
                Complete-VMFailover -VM $vm -ErrorAction Stop
            }
        }

        $result = [PSCustomObject]@{
            Name      = $vm.Name
            Action    = "Failover$Action"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
