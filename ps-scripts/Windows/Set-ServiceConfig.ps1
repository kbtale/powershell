#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Configures system service properties and state

.DESCRIPTION
    Modifies the configuration of a specified system service, including its display name, description, startup type, and operational status. Supports local and remote computers.

.PARAMETER Name
    Specifies the name of the service to configure.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER DisplayName
    Specifies a new display name for the service.

.PARAMETER Description
    Specifies a new description for the service.

.PARAMETER StartupType
    Specifies the startup type for the service (Automatic, Manual, or Disabled).

.PARAMETER Status
    Specifies the desired operational status (Running, Stopped, or Paused).

.EXAMPLE
    PS> ./Set-ServiceConfig.ps1 -Name "LanmanWorkstation" -StartupType Automatic -Status Running

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$Name,

    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$DisplayName,

    [string]$Description,

    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$StartupType,

    [ValidateSet('Running', 'Stopped', 'Paused')]
    [string]$Status
)

Process {
    try {
        $setParams = @{
            'Name'         = $Name
            'ComputerName' = $ComputerName
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('DisplayName')) {
            $setParams.Add('DisplayName', $DisplayName)
        }

        if ($PSBoundParameters.ContainsKey('Description')) {
            $setParams.Add('Description', $Description)
        }

        if ($PSBoundParameters.ContainsKey('StartupType')) {
            $setParams.Add('StartupType', $StartupType)
        }

        if ($PSBoundParameters.ContainsKey('Status')) {
            $setParams.Add('Status', $Status)
        }

        if ($setParams.Count -gt 3) {
            Set-Service @setParams
        }

        $updatedService = Get-Service -Name $Name -ComputerName $ComputerName -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            Name        = $updatedService.Name
            DisplayName = $updatedService.DisplayName
            Status      = $updatedService.Status
            StartupType = $updatedService.StartType
            Computer    = $ComputerName
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
