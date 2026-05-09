#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Runs a script in the guest OS of the specified virtual machine
.DESCRIPTION
    Executes a PowerShell, Bat, or Bash script in the guest OS of a VM.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the virtual machine
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER ScriptText
    Text of the script to run
.PARAMETER GuestCredential
    PSCredential for authenticating with the guest OS
.PARAMETER ScriptType
    Type of the script: PowerShell, Bat, or Bash
.PARAMETER ToolsWaitSecs
    Seconds to wait for VMware Tools connection
.EXAMPLE
    PS> ./Invoke-VMScript.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "MyVM" -ScriptText "Get-Process"
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
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$ScriptText,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [pscredential]$GuestCredential,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet('PowerShell', 'Bat', 'Bash')]
    [string]$ScriptType = "PowerShell",
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$ToolsWaitSecs = 20
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop
        }
        else {
            $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        }
        if ($null -eq $GuestCredential) {
            $result = Invoke-VMScript -VM $machine -Server $vmServer -ScriptText $ScriptText -ScriptType $ScriptType -ToolsWaitSecs $ToolsWaitSecs -Confirm:$false -ErrorAction Stop
        }
        else {
            $result = Invoke-VMScript -VM $machine -Server $vmServer -ScriptText $ScriptText -ScriptType $ScriptType -GuestCredential $GuestCredential -ToolsWaitSecs $ToolsWaitSecs -Confirm:$false -ErrorAction Stop
        }
        $result | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
        Write-Output $result
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
