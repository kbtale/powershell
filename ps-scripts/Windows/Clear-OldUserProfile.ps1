#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Removes stale user profiles older than a specified number of days

.DESCRIPTION
    Identifies and deletes user profiles that haven't been accessed for a specific duration. This script is essential for reclaiming disk space on shared systems or RDS servers. Supports local and remote cleanup via CIM.

.PARAMETER Days
    Specifies the inactivity threshold in days. Profiles not used within this period will be targeted for removal.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER WhatIf
    Shows what would happen without actually deleting the profiles.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Clear-OldUserProfile.ps1 -Days 90 -WhatIf

.CATEGORY Windows
#>

[CmdletBinding(SupportsShouldProcess = $true)]
Param
(
    [Parameter(Mandatory = $true)]
    [int]$Days,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process
{
    try
    {
        $session = $null
        $cimParams = @{
            'ClassName'   = 'Win32_UserProfile'
            'Filter'      = "Special = False"
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
            $session = New-CimSession @sessionParams
            $cimParams.Add('CimSession', $session)
        }

        $profiles = Get-CimInstance @cimParams
        $cutoffDate = (Get-Date).AddDays(-$Days)

        $staleProfiles = $profiles | Where-Object { $_.LastUseTime -lt $cutoffDate -and $_.LastUseTime -ne $null }

        $results = foreach ($profile in $staleProfiles)
        {
            $path = $profile.LocalPath
            if ($PSCmdlet.ShouldProcess("Profile: $path (Last Use: $($profile.LastUseTime))", "Remove Profile"))
            {
                $profile | Remove-CimInstance @cimParams
                [PSCustomObject]@{
                    LocalPath    = $path
                    LastUseTime  = $profile.LastUseTime
                    Status       = "Removed"
                    ComputerName = $ComputerName
                }
            }
            else
            {
                [PSCustomObject]@{
                    LocalPath    = $path
                    LastUseTime  = $profile.LastUseTime
                    Status       = "Skipped (WhatIf)"
                    ComputerName = $ComputerName
                }
            }
        }

        if ($null -ne $results)
        {
            Write-Output $results
        }
        else
        {
            Write-Verbose "No stale profiles found older than $Days days."
        }
    }
    catch
    {
        throw
    }
    finally
    {
        if ($null -ne $session)
        {
            Remove-CimSession $session
        }
    }
}
