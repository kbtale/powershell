#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves detailed information about running processes

.DESCRIPTION
    Lists active processes on the local or remote computer. This script provides an operational view of resource consumption (CPU, Memory) and process metadata (Path, Company, StartTime).

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER Name
    Specifies the name of the process to retrieve. Supports wildcards.

.PARAMETER Id
    Specifies the process ID (PID) to retrieve specifically.

.PARAMETER IncludeUserName
    If set, attempts to retrieve the user account under which each process is running (Requires elevation).

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-ProcessInfo.ps1 -Name "chrome*"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$Name,

    [int]$Id,

    [switch]$IncludeUserName,

    [pscredential]$Credential
)

Process {
    try {
        $processParams = @{
            'ErrorAction' = 'Stop'
        }

        if (-not [string]::IsNullOrWhiteSpace($Name)) {
            $processParams.Add('Name', $Name)
        }
        elseif ($Id -gt 0) {
            $processParams.Add('Id', $Id)
        }

        if ($IncludeUserName) {
            $processParams.Add('IncludeUserName', $true)
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = {
                    Param($Params)
                    Get-Process @Params | Select-Object Name, Id, CPU, WorkingSet, StartTime, Path, Company, UserName
                }
                'ArgumentList' = $processParams
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = Get-Process @processParams | Select-Object Name, Id, CPU, WorkingSet, StartTime, Path, Company, UserName
        }

        $results = foreach ($proc in $result) {
            [PSCustomObject]@{
                Name         = $proc.Name
                Id           = $proc.Id
                CPU          = if ($proc.CPU) { [math]::Round($proc.CPU, 2) } else { 0 }
                MemoryMB     = if ($proc.WorkingSet) { [math]::Round($proc.WorkingSet / 1MB, 2) } else { 0 }
                StartTime    = $proc.StartTime
                User         = $proc.UserName
                Path         = $proc.Path
                Company      = $proc.Company
                ComputerName = $ComputerName
            }
        }

        Write-Output ($results | Sort-Object CPU -Descending)
    }
    catch {
        throw
    }
}
