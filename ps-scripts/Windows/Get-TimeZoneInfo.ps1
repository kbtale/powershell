#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves current time zone settings

.DESCRIPTION
    Gets the current time zone configured on the local or remote computer. Can also list all available time zones on the system for reference.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER ListAvailable
    If set, returns a list of all time zones available on the system.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-TimeZoneInfo.ps1 -ComputerName "SRV01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [switch]$ListAvailable,

    [pscredential]$Credential
)

Process
{
    try
    {
        $scriptBlock = {
            Param($List)
            if ($List)
            {
                Get-TimeZone -ListAvailable | Select-Object Id, DisplayName, BaseUtcOffset
            }
            else
            {
                Get-TimeZone | Select-Object Id, DisplayName, BaseUtcOffset
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = $ListAvailable
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
            $result = &$scriptBlock -List $ListAvailable
        }

        # Add ComputerName to output
        $results = foreach ($r in $result)
        {
            $r | Add-Member -MemberType NoteProperty -Name ComputerName -Value $ComputerName -PassThru
        }

        Write-Output $results
    }
    catch
    {
        throw
    }
}
