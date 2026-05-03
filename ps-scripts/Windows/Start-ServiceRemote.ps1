#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Starts a stopped system service

.DESCRIPTION
    Triggers the start of a specified service on a local or remote computer. Supports identification by internal name or display name.

.PARAMETER Name
    Specifies the internal name of the service to start.

.PARAMETER DisplayName
    Specifies the display name of the service to start.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Start-ServiceRemote.ps1 -Name "Spooler"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$Name,

    [string]$DisplayName,

    [string]$ComputerName = $env:COMPUTERNAME,

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
                    Param($Params)
                    $srv = Get-Service @Params
                    Start-Service -InputObject $srv
                    $srv | Select-Object Name, DisplayName, Status
                }
                'ArgumentList' = $serviceParams
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $srv = Get-Service @serviceParams
            Start-Service -InputObject $srv
            $result = $srv | Select-Object Name, DisplayName, Status
        }

        $output = [PSCustomObject]@{
            Name         = $result.Name
            Status       = $result.Status
            ComputerName = $ComputerName
            Action       = "Started"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
