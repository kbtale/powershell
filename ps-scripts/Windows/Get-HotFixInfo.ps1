#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves installed hotfixes and software updates

.DESCRIPTION
    Gets the hotfixes (operating system updates) that have been applied to the local or remote computer. This script provides a structured way to audit patch levels and installation history.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.PARAMETER Id
    Specifies the HotFix ID (e.g., KB123456) to retrieve specifically.

.PARAMETER Properties
    Specifies the list of properties to include in the output.

.EXAMPLE
    PS> ./Get-HotFixInfo.ps1 -ComputerName "SRV-WEB-01"

.EXAMPLE
    PS> ./Get-HotFixInfo.ps1 -Id "KB5001234"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential,

    [string]$Id,

    [string[]]$Properties = @('HotFixID', 'Description', 'InstalledOn', 'InstalledBy', 'Caption')
)

Process
{
    try
    {
        $hotFixParams = @{
            'ErrorAction' = 'Stop'
        }

        if (-not [string]::IsNullOrWhiteSpace($ComputerName))
        {
            $hotFixParams.Add('ComputerName', $ComputerName)
        }

        if ($null -ne $Credential)
        {
            $hotFixParams.Add('Credential', $Credential)
        }

        if (-not [string]::IsNullOrWhiteSpace($Id))
        {
            $hotFixParams.Add('Id', $Id)
        }

        $hotfixes = Get-HotFix @hotFixParams

        if ($null -ne $hotfixes)
        {
            $result = $hotfixes | Select-Object -Property $Properties | Sort-Object InstalledOn -Descending
            Write-Output $result
        }
    }
    catch
    {
        throw
    }
}
