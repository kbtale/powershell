#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Start, stop or restart VMware virtual machines
.DESCRIPTION
    Manages multiple VMs with actions: Start, Stop, Restart, Suspend, or Shutdown.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Action
    Action to perform: Start, Stop, Restart, Suspend, or Shutdown
.PARAMETER VirtualMachines
    List of virtual machine names to manage
.EXAMPLE
    PS> ./Manage-VirtualMachines.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Action "Start" -VirtualMachines @("VM1","VM2")
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [ValidateSet("Start", "Stop", "Restart", "Suspend", "Shutdown")]
    [string]$Action,
    [Parameter(Mandatory = $true)]
    [string[]]$VirtualMachines
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $cmdArgs = @{ Server = $vmServer; Confirm = $false; RunAsync = $true; VM = '' }
        if ($Action -eq "Start") {
            foreach ($item in $VirtualMachines) {
                try { $cmdArgs.VM = $item; Start-VM @cmdArgs; Write-Output ([PSCustomObject]@{ Timestamp = $timestamp; Status = "Success"; Message = "VM $item started successfully" }) }
                catch { Write-Output ([PSCustomObject]@{ Timestamp = $timestamp; Status = "Error"; Message = "Failed to start VM $item" }) }
            }
        }
        elseif ($Action -eq "Stop") {
            foreach ($item in $VirtualMachines) {
                try { $cmdArgs.VM = $item; Stop-VM @cmdArgs; Write-Output ([PSCustomObject]@{ Timestamp = $timestamp; Status = "Success"; Message = "VM $item stopped successfully" }) }
                catch { Write-Output ([PSCustomObject]@{ Timestamp = $timestamp; Status = "Error"; Message = "Failed to stop VM $item" }) }
            }
        }
        elseif ($Action -eq "Restart") {
            foreach ($item in $VirtualMachines) {
                try { $cmdArgs.VM = $item; Restart-VM @cmdArgs; Write-Output ([PSCustomObject]@{ Timestamp = $timestamp; Status = "Success"; Message = "VM $item restarted successfully" }) }
                catch { Write-Output ([PSCustomObject]@{ Timestamp = $timestamp; Status = "Error"; Message = "Failed to restart VM $item" }) }
            }
        }
        elseif ($Action -eq "Suspend") {
            foreach ($item in $VirtualMachines) {
                try { $cmdArgs.VM = $item; Suspend-VM @cmdArgs; Write-Output ([PSCustomObject]@{ Timestamp = $timestamp; Status = "Success"; Message = "VM $item suspended successfully" }) }
                catch { Write-Output ([PSCustomObject]@{ Timestamp = $timestamp; Status = "Error"; Message = "Failed to suspend VM $item" }) }
            }
        }
        elseif ($Action -eq "Shutdown") {
            foreach ($item in $VirtualMachines) {
                try { $cmdArgs.Remove("RunAsync"); $cmdArgs.VM = $item; Shutdown-VMGuest @cmdArgs; Write-Output ([PSCustomObject]@{ Timestamp = $timestamp; Status = "Success"; Message = "VM $item shutdown successfully" }) }
                catch { Write-Output ([PSCustomObject]@{ Timestamp = $timestamp; Status = "Error"; Message = "Failed to shutdown VM $item" }) }
            }
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
