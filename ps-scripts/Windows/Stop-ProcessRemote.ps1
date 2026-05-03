#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Stops one or more running processes

.DESCRIPTION
    Terminates active processes on the local or remote computer. Supports stopping by name or ID, and includes a force option to bypass confirmation or termination obstacles.

.PARAMETER Name
    Specifies the name of the process to stop. Supports wildcards.

.PARAMETER Id
    Specifies the process ID (PID) to stop.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Force
    Indicates that the process should be stopped without confirmation or regard for open data.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Stop-ProcessRemote.ps1 -Name "Notepad" -Force

.CATEGORY Windows
#>

[CmdletBinding(DefaultParameterSetName = 'ByName')]
Param
(
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName', ValueFromPipelineByPropertyName = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true, ParameterSetName = 'ById', ValueFromPipelineByPropertyName = $true)]
    [int]$Id,

    [string]$ComputerName = $env:COMPUTERNAME,

    [switch]$Force,

    [pscredential]$Credential
)

Process
{
    try
    {
        $stopParams = @{
            'Force'       = $Force
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            $stopParams.Add('Name', $Name)
        }
        else
        {
            $stopParams.Add('Id', $Id)
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = {
                    Param($Params)
                    Stop-Process @Params
                }
                'ArgumentList' = $stopParams
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential)
            {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
        }
        else
        {
            Stop-Process @stopParams
        }

        $result = [PSCustomObject]@{
            Target       = if ($PSCmdlet.ParameterSetName -eq 'ByName') { $Name } else { $Id }
            ComputerName = $ComputerName
            Action       = "Terminated"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch
    {
        throw
    }
}
