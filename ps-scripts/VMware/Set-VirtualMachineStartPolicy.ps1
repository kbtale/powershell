#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies the virtual machine start policy
.DESCRIPTION
    Configures VM start policy including delays, actions, and heartbeat settings.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the virtual machine
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER StartAction
    VM start action: None or PowerOn
.PARAMETER StartDelay
    Default start delay in seconds
.PARAMETER StartOrder
    Number defining the VM start order
.PARAMETER StopAction
    Default stop action: None, Suspend, PowerOff, or GuestShutdown
.PARAMETER StopDelay
    Default stop delay in seconds
.PARAMETER InheritStartDelayFromHost
    Inherit start delay from the host
.PARAMETER InheritStopActionFromHost
    Inherit stop action from the host
.PARAMETER InheritStopDelayFromHost
    Inherit stop delay from the host
.PARAMETER InheritWaitForHeartbeatFromHost
    Inherit wait for heartbeat from the host
.PARAMETER UnspecifiedStartOrder
    No specific start order defined
.PARAMETER WaitForHeartBeat
    VM should start after receiving a heartbeat
.EXAMPLE
    PS> ./Set-VirtualMachineStartPolicy.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "MyVM" -StartAction "PowerOn"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "byName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$VMId,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("None", "PowerOn")]
    [string]$StartAction = "None",
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$StartDelay,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$StartOrder,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("None", "Suspend", "PowerOff", "GuestShutdown")]
    [string]$StopAction = "None",
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$StopDelay,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$InheritStartDelayFromHost,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$InheritStopActionFromHost,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$InheritStopDelayFromHost,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$InheritWaitForHeartbeatFromHost,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$UnspecifiedStartOrder,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$WaitForHeartBeat
)
Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('VirtualMachineName', 'StartAction', 'StartDelay', 'StopAction', 'StopDelay', 'IsStartDelayInherited', 'IsStopActionInherited', 'IsStopDelayInherited', 'IsWaitForHeartbeatInherited')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop
        }
        else {
            $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        }
        $poli = Get-VMStartPolicy -Server $vmServer -VM $machine -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; StartPolicy = $poli; Confirm = $false }
        if ($StartDelay -gt 0) { $null = Set-VMStartPolicy @cmdArgs -StartDelay $StartDelay }
        if ($StopDelay -gt 0) { $null = Set-VMStartPolicy @cmdArgs -StopDelay $StopDelay }
        if ($StartOrder -gt 0) { $null = Set-VMStartPolicy @cmdArgs -StartOrder $StartOrder }
        if ($PSBoundParameters.ContainsKey('StartAction')) { $null = Set-VMStartPolicy @cmdArgs -StartAction $StartAction }
        if ($PSBoundParameters.ContainsKey('StopAction')) { $null = Set-VMStartPolicy @cmdArgs -StopAction $StopAction }
        if ($PSBoundParameters.ContainsKey('UnspecifiedStartOrder')) { $null = Set-VMStartPolicy @cmdArgs -UnspecifiedStartOrder:$UnspecifiedStartOrder }
        if ($PSBoundParameters.ContainsKey('WaitForHeartBeat')) { $null = Set-VMStartPolicy @cmdArgs -WaitForHeartBeat $WaitForHeartBeat }
        if ($PSBoundParameters.ContainsKey('InheritStartDelayFromHost')) { $null = Set-VMStartPolicy @cmdArgs -InheritStartDelayFromHost:$InheritStartDelayFromHost }
        if ($PSBoundParameters.ContainsKey('InheritStopActionFromHost')) { $null = Set-VMStartPolicy @cmdArgs -InheritStopActionFromHost:$InheritStopActionFromHost }
        if ($PSBoundParameters.ContainsKey('InheritStopDelayFromHost')) { $null = Set-VMStartPolicy @cmdArgs -InheritStopDelayFromHost:$InheritStopDelayFromHost }
        if ($PSBoundParameters.ContainsKey('InheritWaitForHeartbeatFromHost')) { $null = Set-VMStartPolicy @cmdArgs -InheritWaitForHeartbeatFromHost:$InheritWaitForHeartbeatFromHost }
        $result = Get-VMStartPolicy -Server $vmServer -VM $machine -ErrorAction Stop | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
