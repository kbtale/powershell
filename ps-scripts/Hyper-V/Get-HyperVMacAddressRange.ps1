#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Retrieves the MAC address range from a Hyper-V host

.DESCRIPTION
    Gets the dynamic MAC address pool limits (Minimum and Maximum) configured on a specified Hyper-V host.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.EXAMPLE
    PS> ./Get-HyperVMacAddressRange.ps1 -ComputerName "HV-HOST-01"

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
            ComputerName      = $hostInfo.Name
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
