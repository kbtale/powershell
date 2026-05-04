#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Executes a command on a virtual machine via PowerShell Direct

.DESCRIPTION
    Establishes a PowerShell Direct session to a specifies Hyper-V virtual machine and executes a script block.

.PARAMETER VMName
    Specifies the name of the virtual machine.

.PARAMETER Credential
    Specifies the credentials for the guest operating system.

.PARAMETER ScriptBlock
    Optional. Specifies the command(s) to execute on the VM. Defaults to retrieving the guest hostname.

.EXAMPLE
    PS> ./Invoke-HyperVVMCommand.ps1 -VMName "Web01" -Credential (Get-Credential) -ScriptBlock { Get-Service }

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [PSCredential]$Credential,

    [scriptblock]$ScriptBlock = { $env:COMPUTERNAME }
)

Process {
    try {
        $session = New-PSSession -VMName $VMName -Credential $Credential -ErrorAction Stop
        
        $output = Invoke-Command -Session $session -ScriptBlock $ScriptBlock -ErrorAction Stop

        $result = [PSCustomObject]@{
            VMName    = $VMName
            Output    = $output
            Action    = "CommandExecutedViaPSDirect"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
    finally {
        if ($session) {
            Remove-PSSession -Session $session
        }
    }
}
