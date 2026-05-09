#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Configures hosts firmware settings
.DESCRIPTION
    Resets host firmware to defaults or restores from a backup bundle.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Name of the host to modify firmware settings
.PARAMETER HostCredential
    Credential for authenticating with the host when restoring
.PARAMETER SourcePath
    Path to the host configuration backup bundle to restore
.EXAMPLE
    PS> ./Set-HostFirmware.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "Reset")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Reset")]
    [Parameter(Mandatory = $true, ParameterSetName = "Restore")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "Reset")]
    [Parameter(Mandatory = $true, ParameterSetName = "Restore")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "Reset")]
    [Parameter(Mandatory = $true, ParameterSetName = "Restore")]
    [string]$HostName,
    [Parameter(Mandatory = $true, ParameterSetName = "Restore")]
    [pscredential]$HostCredential,
    [Parameter(ParameterSetName = "Restore")]
    [string]$SourcePath
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        Set-VMHost -VMHost $vmHost -State 'Maintenance'
        if ($PSCmdlet.ParameterSetName -eq "Reset") {
            $null = Set-VMHostFirmware -Server $vmServer -VMHost $vmHost -ResetToDefaults -Confirm:$false -ErrorAction Stop
        }
        else {
            $null = Set-VMHostFirmware -Server $vmServer -VMHost $vmHost -Restore -HostCredential $HostCredential -SourcePath $SourcePath -Force:$true -Confirm:$false -ErrorAction Stop
        }
        $result = Get-VMHostFirmware -Server $vmServer -VMHost $vmHost -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
