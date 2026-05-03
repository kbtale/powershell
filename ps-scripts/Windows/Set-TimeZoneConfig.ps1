#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Sets the system time zone to a specified ID

.DESCRIPTION
    Updates the time zone configuration on a local or remote computer. This operation requires administrative privileges on the target system.

.PARAMETER Id
    Specifies the identifier of the time zone (e.g., "Pacific Standard Time"). Use Get-TimeZone -ListAvailable to see valid IDs.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-TimeZoneConfig.ps1 -Id "W. Europe Standard Time"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$Id,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process
{
    try
    {
        $scriptBlock = {
            Param($TimeZoneId)
            Set-TimeZone -Id $TimeZoneId -ErrorAction Stop
            Get-TimeZone | Select-Object Id, DisplayName, BaseUtcOffset
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = $Id
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential)
            {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else
        {
            $result = &$scriptBlock -TimeZoneId $Id
        }

        $output = [PSCustomObject]@{
            Id           = $result.Id
            DisplayName  = $result.DisplayName
            ComputerName = $ComputerName
            Action       = "Set"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch
    {
        throw
    }
}
