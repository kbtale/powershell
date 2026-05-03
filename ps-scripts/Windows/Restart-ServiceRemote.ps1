#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Restarts a system service on a local or remote computer

.DESCRIPTION
    Safely restarts a specified system service. If the computer name is provided, it uses remote management to perform the operation. This script includes verification to ensure the service returns to a running state.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Name
    Specifies the name of the service to restart.

.PARAMETER Force
    Indicates that the service should be restarted even if it has dependent services.

.EXAMPLE
    PS> ./Restart-ServiceRemote.ps1 -ComputerName "SRV01" -Name "Spooler"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$Name,

    [string]$ComputerName = $env:COMPUTERNAME,

    [switch]$Force
)

Process {
    try {
        $serviceParams = @{
            'Name'         = $Name
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }

        if ($Force) {
            $serviceParams.Add('Force', $true)
        }

        Write-Verbose "Attempting to restart service '$Name' on '$ComputerName'..."
        Restart-Service @serviceParams

        Start-Sleep -Seconds 2
        $status = Get-Service -Name $Name -ComputerName $ComputerName -ErrorAction Stop
            
        $result = [PSCustomObject]@{
            ServiceName  = $Name
            ComputerName = $ComputerName
            Status       = $status.Status
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
