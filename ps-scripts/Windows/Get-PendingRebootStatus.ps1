#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Checks if a system has a pending reboot

.DESCRIPTION
    Analyzes multiple registry keys and system states to determine if a local or remote computer requires a reboot. This is critical for post-patching verification and configuration management.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-PendingRebootStatus.ps1

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            $pending = @{
                'WindowsUpdate'  = $false
                'ComponentBased' = $false
                'FileRename'     = $false
                'ComputerRename' = $false
            }

            if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") {
                $pending.WindowsUpdate = $true
            }

            if (Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") {
                $pending.ComponentBased = $true
            }

            $fileRename = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager" -Name "PendingFileRenameOperations" -ErrorAction SilentlyContinue
            if ($fileRename.PendingFileRenameOperations) {
                $pending.FileRename = $true
            }

            $compRename = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" -ErrorAction SilentlyContinue
            $compRenameFuture = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" -ErrorAction SilentlyContinue
            if ($compRename.ComputerName -ne $compRenameFuture.ComputerName) {
                $pending.ComputerRename = $true
            }

            $isPending = $pending.Values -contains $true
            
            [PSCustomObject]@{
                IsPendingReboot = $isPending
                WindowsUpdate   = $pending.WindowsUpdate
                ComponentBased  = $pending.ComponentBased
                FileRename      = $pending.FileRename
                ComputerRename  = $pending.ComputerRename
                ComputerName    = $env:COMPUTERNAME
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
