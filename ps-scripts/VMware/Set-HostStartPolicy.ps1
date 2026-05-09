#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies the host default start policy
.DESCRIPTION
    Configures host start policy including delays, stop action, and heartbeat settings.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostId
    ID of the host to modify
.PARAMETER HostName
    Name of the host to modify
.PARAMETER Enabled
    Enable the service that controls host start policies
.PARAMETER StartDelay
    Default start delay in seconds
.PARAMETER StopAction
    Default action when the server stops
.PARAMETER StopDelay
    Default stop delay in seconds
.PARAMETER WaitForHeartBeat
    VMs should start after receiving a heartbeat
.EXAMPLE
    PS> ./Set-HostStartPolicy.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -StartDelay 30
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
    [string]$HostId,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$HostName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [bool]$Enabled,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$StartDelay,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("None", "Suspend", "PowerOff", "GuestShutdown")]
    [string]$StopAction,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$StopDelay,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [bool]$WaitForHeartBeat
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $vmhost = Get-VMHost -Server $vmServer -Id $HostId -ErrorAction Stop
        }
        else {
            $vmhost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        }
        $poli = Get-VMHostStartPolicy -Server $vmServer -VMHost $vmhost -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; VMHostStartPolicy = $poli; Confirm = $false }
        if ($PSBoundParameters.ContainsKey('Enabled')) { Set-VMHostStartPolicy @cmdArgs -Enabled $Enabled }
        if ($StartDelay -gt 0) { Set-VMHostStartPolicy @cmdArgs -StartDelay $StartDelay }
        if ($StopDelay -gt 0) { Set-VMHostStartPolicy @cmdArgs -StopDelay $StopDelay }
        if ($PSBoundParameters.ContainsKey('StopAction')) { Set-VMHostStartPolicy @cmdArgs -StopAction $StopAction }
        if ($PSBoundParameters.ContainsKey('WaitForHeartBeat')) { Set-VMHostStartPolicy @cmdArgs -WaitForHeartBeat $WaitForHeartBeat }
        $result = Get-VMHostStartPolicy -Server $vmServer -VMHost $vmhost -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
