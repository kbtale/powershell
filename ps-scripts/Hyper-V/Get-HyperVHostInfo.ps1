#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Retrieves properties of a Hyper-V host

.DESCRIPTION
    Gets administrative and hardware properties for a specified Microsoft Hyper-V host. Supports remote auditing via ComputerName or CIM Session.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Properties
    Optional. Specifies an array of properties to retrieve. Defaults to standard administrative properties. Use '*' for all.

.EXAMPLE
    PS> ./Get-HyperVHostInfo.ps1 -ComputerName "HV-HOST-01"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [string[]]$Properties = @('ComputerName', 'VirtualHardDiskPath', 'VirtualMachinePath', 'LogicalProcessorCount', 'MemoryCapacity', 'MacAddressMinimum', 'MacAddressMaximum', 'FullyQualifiedDomainName')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }

        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $hostInfo = Get-VMHost @params
        $result = $hostInfo | Select-Object $Properties

        Write-Output $result
    }
    catch {
        throw
    }
}
