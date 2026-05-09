#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Invokes a command for the specified host (Start, Stop, Suspend, Restart)
.DESCRIPTION
    Executes a power command on a host identified by ID or name.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the host
.PARAMETER Name
    Name of the host
.PARAMETER Command
    Command to execute: Start, Stop, Suspend, or Restart
.PARAMETER TimeoutSeconds
    Timeout in seconds for the operation
.PARAMETER Evacuate
    Automatically reregister compatible VMs on restart
.EXAMPLE
    PS> ./Invoke-HostCommand.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "esxi01" -Command "Restart"
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
    [string]$ID,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$Name,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [ValidateSet('Start', 'Stop', 'Suspend', 'Restart')]
    [string]$Command,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$TimeoutSeconds = 300,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$Evacuate
)
Process {
    $vmServer = $null
    try {
        if ($TimeoutSeconds -le 0) { $TimeoutSeconds = 300 }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $vmHost = Get-VMHost -Server $vmServer -ID $ID -ErrorAction Stop
        }
        else {
            $vmHost = Get-VMHost -Server $vmServer -Name $Name -ErrorAction Stop
        }
        switch ($Command) {
            "Start"   { Start-VMHost -VMHost $vmHost -TimeoutSeconds $TimeoutSeconds -Server $vmServer -Confirm:$false -ErrorAction Stop }
            "Stop"    { Stop-VMHost -VMHost $vmHost -Server $vmServer -Force:$true -Confirm:$false -ErrorAction Stop }
            "Suspend" { Suspend-VMHost -VMHost $vmHost -TimeoutSeconds $TimeoutSeconds -Evacuate:$Evacuate -Server $vmServer -Confirm:$false -ErrorAction Stop }
            "Restart" { Restart-VMHost -VMHost $vmHost -Evacuate:$Evacuate -Server $vmServer -Force:$true -Confirm:$false -ErrorAction Stop }
        }
        $output = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            Message   = "Command $Command successfully executed on host $($vmHost.Name)"
        }
        Write-Output $output
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
