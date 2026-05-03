#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Stops a running system service

.DESCRIPTION
    Terminates a specified service on a local or remote computer. Includes support for stopping services with dependent services via the Force parameter.

.PARAMETER Name
    Specifies the internal name of the service to stop.

.PARAMETER DisplayName
    Specifies the display name of the service to stop.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Force
    If set, stops the service even if it has dependent services.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Stop-ServiceRemote.ps1 -Name "Spooler" -Force

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$Name,

    [string]$DisplayName,

    [string]$ComputerName = $env:COMPUTERNAME,

    [switch]$Force,

    [pscredential]$Credential
)

Process {
    try {
        $serviceParams = @{
            'ErrorAction' = 'Stop'
        }

        if (-not [string]::IsNullOrWhiteSpace($Name)) {
            $serviceParams.Add('Name', $Name)
        }
        elseif (-not [string]::IsNullOrWhiteSpace($DisplayName)) {
            $serviceParams.Add('DisplayName', $DisplayName)
        }
        else {
            throw "Either Name or DisplayName must be specified."
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = {
                    Param($Params, $ForceStop)
                    $srv = Get-Service @Params
                    Stop-Service -InputObject $srv -Force:$ForceStop
                    $srv | Select-Object Name, DisplayName, Status
                }
                'ArgumentList' = @($serviceParams, $Force)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $srv = Get-Service @serviceParams
            Stop-Service -InputObject $srv -Force:$Force
            $result = $srv | Select-Object Name, DisplayName, Status
        }

        $output = [PSCustomObject]@{
            Name         = $result.Name
            Status       = $result.Status
            ComputerName = $ComputerName
            Action       = "Stopped"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
