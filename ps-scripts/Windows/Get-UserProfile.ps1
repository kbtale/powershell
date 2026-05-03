#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves information about user profiles on a computer

.DESCRIPTION
    Lists local and domain user profiles stored on a computer. This script provides details such as the profile path, last use time, and SID, helping identify stale profiles and manage disk space.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER IncludeSpecial
    If set, includes system and special profiles (e.g., LocalSystem, NetworkService) in the list.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-UserProfile.ps1 -ComputerName "SRV-DATA-01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [switch]$IncludeSpecial,

    [pscredential]$Credential
)

Process
{
    try
    {
        $cimParams = @{
            'ClassName'   = 'Win32_UserProfile'
            'ErrorAction' = 'Stop'
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $sessionParams = @{
                'ComputerName' = $ComputerName
            }
            if ($null -ne $Credential)
            {
                $sessionParams.Add('Credential', $Credential)
            }
            $cimParams.Add('CimSession', (New-CimSession @sessionParams))
        }

        $profiles = Get-CimInstance @cimParams

        if (-not $IncludeSpecial)
        {
            $profiles = $profiles | Where-Object { $_.Special -eq $false }
        }

        $results = foreach ($p in $profiles)
        {
            $account = $null
            try
            {
                # Attempt to resolve SID to a name using CIM (works for local and cached domain accounts)
                $account = Get-CimInstance -ClassName Win32_UserAccount -Filter "SID = '$($p.SID)'" -ErrorAction SilentlyContinue
            }
            catch {}

            [PSCustomObject]@{
                ComputerName = $ComputerName
                LocalPath    = $p.LocalPath
                LastUseTime  = $p.LastUseTime
                SID          = $p.SID
                UserName     = if ($account) { "$($account.Domain)\$($account.Name)" } else { "Unknown" }
                IsLoaded     = $p.Loaded
            }
        }

        Write-Output ($results | Sort-Object LastUseTime -Descending)
    }
    catch
    {
        throw
    }
    finally
    {
        if ($cimParams.ContainsKey('CimSession'))
        {
            Remove-CimSession $cimParams.CimSession
        }
    }
}
