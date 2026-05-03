#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves consolidated system and operating system information

.DESCRIPTION
    Provides a comprehensive overview of system properties, including BIOS details, OS version, hardware specifications, and network configuration. Supports local and remote execution.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.PARAMETER Property
    Specifies the specific properties to retrieve. Supports wildcards. Defaults to essential summary properties.

.EXAMPLE
    PS> ./Get-ComputerInfo.ps1 -ComputerName "WORKSTATION01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential,

    [string[]]$Property = @(
        'CsName',
        'OsName',
        'OsVersion',
        'OsArchitecture',
        'BiosSeralNumber',
        'CsManufacturer',
        'CsModel',
        'OsInstallDate',
        'OsLastBootUpTime'
    )
)

Process
{
    try
    {
        $infoParams = @{
            'Property'    = $Property
            'ErrorAction' = 'Stop'
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $sessionParams = @{
                'ComputerName' = $ComputerName
            }
            if ($null -ne $Credential)
            {
                $sessionParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @sessionParams -ScriptBlock {
                Param($Prop)
                Get-ComputerInfo -Property $Prop
            } -ArgumentList $Property
        }
        else
        {
            $result = Get-ComputerInfo @infoParams
        }

        Write-Output $result
    }
    catch
    {
        throw
    }
}
