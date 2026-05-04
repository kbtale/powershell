#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits the dynamic MAC address pool range

.DESCRIPTION
    Retrieves the minimum and maximum MAC addresses used by the dynamic MAC address pool on a Microsoft Hyper-V host.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.EXAMPLE
    PS> ./Get-HyperVHostMacRange.ps1 -ComputerName "HV-Node-01"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $hostInfo = Get-VMHost @params
        
        $result = [PSCustomObject]@{
            ComputerName      = $hostInfo.ComputerName
            MacAddressMinimum = $hostInfo.MacAddressMinimum
            MacAddressMaximum = $hostInfo.MacAddressMaximum
            Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
