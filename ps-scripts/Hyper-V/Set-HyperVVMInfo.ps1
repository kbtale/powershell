#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Updates virtual machine configuration and metadata

.DESCRIPTION
    A comprehensive utility to update various Microsoft Hyper-V virtual machine properties, including naming, notes, storage locations, and resource orchestration in a single call.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the current name or ID of the virtual machine.

.PARAMETER NewName
    Optional. Renames the virtual machine.

.PARAMETER Notes
    Optional. Updates the descriptive notes associated with the VM.

.PARAMETER SnapshotFileLocation
    Optional. Updates the directory where checkpoint/snapshot files are stored.

.PARAMETER SmartPagingFilePath
    Optional. Updates the directory where smart paging files are stored.

.PARAMETER AutomaticStartAction
    Optional. Action to take when the host starts (Nothing, StartIfRunning, Start).

.PARAMETER AutomaticStopAction
    Optional. Action to take when the host shuts down (TurnOff, Save, ShutDown).

.EXAMPLE
    PS> ./Set-HyperVVMInfo.ps1 -Name "WebSrv-01" -NewName "WebSrv-PROD-01" -Notes "Production Web Server"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$NewName,

    [string]$Notes,

    [string]$SnapshotFileLocation,

    [string]$SmartPagingFilePath,

    [ValidateSet('Nothing', 'StartIfRunning', 'Start')]
    [string]$AutomaticStartAction,

    [ValidateSet('TurnOff', 'Save', 'ShutDown')]
    [string]$AutomaticStopAction
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

        $setParams = @{ 'VM' = $vm; 'ErrorAction' = 'Stop' }
        if ($NewName) { $setParams.Add('NewVMName', $NewName) }
        if ($PSBoundParameters.ContainsKey('Notes')) { $setParams.Add('Notes', $Notes) }
        if ($SnapshotFileLocation) { $setParams.Add('SnapshotFileLocation', $SnapshotFileLocation) }
        if ($SmartPagingFilePath) { $setParams.Add('SmartPagingFilePath', $SmartPagingFilePath) }
        if ($AutomaticStartAction) { $setParams.Add('AutomaticStartAction', $AutomaticStartAction) }
        if ($AutomaticStopAction) { $setParams.Add('AutomaticStopAction', $AutomaticStopAction) }

        if ($setParams.Count -gt 2) {
            Set-VM @setParams
        }

        $updatedVM = Get-VM -ComputerName $ComputerName -Id $vm.Id
        
        $result = [PSCustomObject]@{
            Name                 = $updatedVM.Name
            Notes                = $updatedVM.Notes
            SnapshotLocation     = $updatedVM.SnapshotFileLocation
            SmartPagingPath      = $updatedVM.SmartPagingFilePath
            AutomaticStartAction = $updatedVM.AutomaticStartAction
            AutomaticStopAction  = $updatedVM.AutomaticStopAction
            Action               = "VMPropertiesUpdated"
            Status               = "Success"
            Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
