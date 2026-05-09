#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Install VMtools on the virtual machine
.DESCRIPTION
    Installs VMware Tools on a VM guest OS with optional drive letter and reboot control.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER GuestCredential
    PSCredential for authenticating with the guest OS
.PARAMETER VMId
    ID of the virtual machine
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER DriveLetter
    Virtual CD drive with the VMware tools
.PARAMETER NoReboot
    Do not reboot the system after installation
.EXAMPLE
    PS> ./Install-Tools.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -GuestCredential $guestCred -VMName "MyVM"
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
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [pscredential]$GuestCredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$VMId,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$DriveLetter,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$NoReboot
)
Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('OSFullName', 'State', 'IPAddress', 'Disks', 'ConfiguredGuestId', 'ToolsVersion')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop
        }
        else {
            $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        }
        Mount-Tools -VM $machine -Server $vmServer -ErrorAction SilentlyContinue
        Invoke-Command -ComputerName $machine.Name -Credential $GuestCredential -ScriptBlock { & "$($Using:DriveLetter):\setup.exe" /s /v "/qn reboot=r" }
        Update-Tools -VM $machine -Server $vmServer -NoReboot:$NoReboot -ErrorAction Stop | Wait-Tools -ErrorAction Stop
        Dismount-Tools -VM $machine -Server $vmServer -ErrorAction Stop
        $result = Get-VMGuest -VM $machine -Server $vmServer -ErrorAction Stop | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
