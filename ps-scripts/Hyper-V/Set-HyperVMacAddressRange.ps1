#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures the dynamic MAC address range for a Hyper-V host

.DESCRIPTION
    Sets the minimum and maximum limits for the dynamic MAC address pool on a specified Microsoft Hyper-V host.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Minimum
    Specifies the minimum MAC address in hexadecimal format (e.g., 00155D000000).

.PARAMETER Maximum
    Specifies the maximum MAC address in hexadecimal format (e.g., 00155DFFFFFF).

.EXAMPLE
    PS> ./Set-HyperVMacAddressRange.ps1 -Minimum "00155D010000" -Maximum "00155D01FFFF"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9A-Fa-f]{12}$')]
    [string]$Minimum,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9A-Fa-f]{12}$')]
    [string]$Maximum
)

Process {
    try {
        $params = @{
            'ComputerName'      = $ComputerName
            'MacAddressMinimum' = $Minimum
            'MacAddressMaximum' = $Maximum
            'Confirm'           = $false
            'ErrorAction'       = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        Set-VMHost @params

        $hostInfo = Get-VMHost -ComputerName $ComputerName -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            ComputerName      = $hostInfo.Name
            MacAddressMinimum = $hostInfo.MacAddressMinimum
            MacAddressMaximum = $hostInfo.MacAddressMaximum
            Action            = "MacAddressRangeUpdated"
            Status            = "Success"
            Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
