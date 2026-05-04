#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures VM action on critical error

.DESCRIPTION
    Configures the action to take when a Microsoft Hyper-V virtual machine encounters a critical error (typically storage disconnect), and sets the timeout duration.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER Action
    Specifies the action to take (None or Pause).

.PARAMETER TimeoutMinutes
    Specifies the timeout duration in minutes before the VM is powered off if it remains in critical pause.

.EXAMPLE
    PS> ./Set-HyperVVMAutomaticCriticalError.ps1 -Name "FileSrv" -Action Pause -TimeoutMinutes 30

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet('None', 'Pause')]
    [string]$Action,

    [Parameter(Mandatory = $true)]
    [int]$TimeoutMinutes
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

        Set-VM -VM $vm -AutomaticCriticalErrorAction $Action -AutomaticCriticalErrorActionTimeout $TimeoutMinutes -ErrorAction Stop

        $result = [PSCustomObject]@{
            Name                        = $vm.Name
            AutomaticCriticalErrorAction = $Action
            TimeoutMinutes              = $TimeoutMinutes
            Action                      = "CriticalErrorActionUpdated"
            Status                      = "Success"
            Timestamp                   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
