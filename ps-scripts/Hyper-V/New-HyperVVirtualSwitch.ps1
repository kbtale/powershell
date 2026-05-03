#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Creates a new virtual switch on a Hyper-V host

.DESCRIPTION
    Provisions a new Microsoft Hyper-V virtual switch. Supports External (physical NIC bound), Internal (Host-Guest), and Private (Guest-only) switch types.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name of the new virtual switch.

.PARAMETER SwitchType
    Specifies the type of virtual switch to create (External, Internal, Private).

.PARAMETER NetAdapterName
    Required for External switches. Specifies the name of the physical network adapter to bind to.

.PARAMETER AllowManagementOS
    Only for External switches. If set, allows the management OS to share the physical network adapter. Defaults to true.

.PARAMETER EnableIov
    If set, enables Single Root I/O Virtualization (SR-IOV) on the virtual switch.

.PARAMETER Notes
    Optional. Specifies notes for the virtual switch.

.EXAMPLE
    PS> ./New-HyperVVirtualSwitch.ps1 -Name "vSwitch-External" -SwitchType External -NetAdapterName "Ethernet"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet('External', 'Internal', 'Private')]
    [string]$SwitchType,

    [string]$NetAdapterName,

    [bool]$AllowManagementOS = $true,

    [switch]$EnableIov,

    [string]$Notes
)

Process {
    try {
        $params = @{
            'Name'         = $Name
            'ComputerName' = $ComputerName
            'Notes'        = $Notes
            'EnableIov'    = $EnableIov.IsPresent
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        if ($SwitchType -eq 'External') {
            if (-not $NetAdapterName) {
                throw "NetAdapterName is required when SwitchType is 'External'."
            }
            $params.Add('NetAdapterName', $NetAdapterName)
            $params.Add('AllowManagementOS', $AllowManagementOS)
        }
        else {
            $params.Add('SwitchType', $SwitchType)
        }

        $vSwitch = New-VMSwitch @params

        $result = [PSCustomObject]@{
            Name               = $vSwitch.Name
            ID                 = $vSwitch.Id
            SwitchType         = $vSwitch.SwitchType
            AllowManagementOS  = $vSwitch.AllowManagementOS
            Action             = "VirtualSwitchCreated"
            Status             = "Success"
            Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
