#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves detailed information about system services

.DESCRIPTION
    Gets one or more services on a local or remote computer. This script provides a cleaner interface than the native Get-Service, returning structured data objects that include essential operational properties.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER Name
    Specifies the name of the service to retrieve. Supports wildcards.

.PARAMETER DisplayName
    Specifies the display name of the service to retrieve. Supports wildcards.

.PARAMETER Properties
    Specifies the list of properties to include in the output. Use '*' for all properties.

.EXAMPLE
    PS> ./Get-ServiceInfo.ps1 -ComputerName "SRV01" -Name "WinRM"

.EXAMPLE
    PS> ./Get-ServiceInfo.ps1 -DisplayName "*SQL*"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(ValueFromPipeline = $true)]
    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$Name,

    [string]$DisplayName,

    [string[]]$Properties = @('Name', 'DisplayName', 'Status', 'StartType', 'CanStop', 'CanPauseAndContinue')
)

Process
{
    try
    {
        $getServiceParams = @{
            'ErrorAction' = 'Stop'
        }

        if (-not [string]::IsNullOrWhiteSpace($ComputerName))
        {
            $getServiceParams.Add('ComputerName', $ComputerName)
        }

        if (-not [string]::IsNullOrWhiteSpace($Name))
        {
            $getServiceParams.Add('Name', $Name)
        }
        elseif (-not [string]::IsNullOrWhiteSpace($DisplayName))
        {
            $getServiceParams.Add('DisplayName', $DisplayName)
        }

        $services = Get-Service @getServiceParams

        if ($null -ne $services)
        {
            $result = $services | Select-Object -Property $Properties
            Write-Output $result
        }
    }
    catch
    {
        throw
    }
}
