#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Updates the dynamic MAC address pool range

.DESCRIPTION
    Configures the minimum and maximum MAC addresses for the dynamic MAC address pool on a Microsoft Hyper-V host.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER MacAddressMinimum
    Specifies the minimum MAC address (e.g., "00155D000000").

.PARAMETER MacAddressMaximum
    Specifies the maximum MAC address (e.g., "00155DFFFFFF").

.EXAMPLE
    PS> ./Set-HyperVHostMacRange.ps1 -MacAddressMinimum "00155D010100" -MacAddressMaximum "00155D0101FF"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$MacAddressMinimum,

    [Parameter(Mandatory = $true)]
    [string]$MacAddressMaximum
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $setParams = @{ 'MacAddressMinimum' = $MacAddressMinimum; 'MacAddressMaximum' = $MacAddressMaximum; 'ErrorAction' = 'Stop' }
        if ($Credential) { $setParams.Add('Credential', $Credential) }
        else { $setParams.Add('ComputerName', $ComputerName) }

        Set-VMHost @setParams

        $updatedHost = Get-VMHost -ComputerName $ComputerName
        
        $result = [PSCustomObject]@{
            ComputerName      = $updatedHost.ComputerName
            MacAddressMinimum = $updatedHost.MacAddressMinimum
            MacAddressMaximum = $updatedHost.MacAddressMaximum
            Action            = "MacRangeUpdated"
            Status            = "Success"
            Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
