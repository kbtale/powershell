#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits a specific virtual switch configuration

.DESCRIPTION
    Retrieves detailed properties for a specified Microsoft Hyper-V virtual switch, including switch type, management OS access, IOV status, and associated network adapters.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual switch.

.EXAMPLE
    PS> ./Get-HyperVVirtualSwitchDetail.ps1 -Name "vSwitch-External"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $vSwitch = Get-VMSwitch @params | Where-Object { $_.Name -eq $Name -or $_.Id -eq $Name }

        if (-not $vSwitch) {
            throw "Virtual switch '$Name' not found on '$ComputerName'."
        }

        $result = [PSCustomObject]@{
            Name               = $vSwitch.Name
            Id                 = $vSwitch.Id
            SwitchType         = $vSwitch.SwitchType
            AllowManagementOS  = $vSwitch.AllowManagementOS
            IovEnabled         = $vSwitch.IovEnabled
            NetAdapterInterfaceDescription = $vSwitch.NetAdapterInterfaceDescription
            BandwidthReservationMode = $vSwitch.BandwidthReservationMode
            Notes              = $vSwitch.Notes
            ComputerName       = $vSwitch.ComputerName
            Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
