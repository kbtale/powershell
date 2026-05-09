#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new virtual switch
.DESCRIPTION
    Creates a new standard virtual switch on a specified host.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name for the new virtual switch
.PARAMETER VMHost
    Host on which to create the virtual switch
.PARAMETER PortNumber
    Number of ports for the switch
.EXAMPLE
    PS> ./New-VirtualSwitch.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "vSwitch1" -VMHost "esx01.contoso.com" -PortNumber 120
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$VMHost,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [int32]$PortNumber
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Name = $Name; VMHost = $VMHost; Confirm = $false }
        if ($PortNumber -gt 0) { $cmdArgs.Add('NumPorts', $PortNumber) }
        $result = New-VirtualSwitch @cmdArgs | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}