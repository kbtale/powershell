#Requires -Version 5.1

<#
.SYNOPSIS
    User Management: Safely deletes local user profiles older than N days
.DESCRIPTION
    Queries the system for inactive local user profiles using CIM and safely deletes them to free up disk space. Skips special, system, and currently active profiles.
.PARAMETER Days
    The age threshold in days. Profiles not used for longer than this period will be deleted.
.EXAMPLE
    PS> ./Remove-LocalProfilesOlderThan.ps1 -Days 90 -WhatIf
.CATEGORY User Management
#>

[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter(Mandatory = $true)]
    [int]$Days
)

Process {
    try {
        if ($Days -le 0) {
            throw "Days parameter must be a positive integer."
        }

        $thresholdDate = (Get-Date).AddDays(-$Days)
        Write-Verbose "Threshold date is set to: $thresholdDate"

        $profiles = Get-CimInstance -ClassName Win32_UserProfile -ErrorAction Stop
        
        $results = @()
        foreach ($profile in $profiles) {
            # Skip system special profiles
            if ($profile.Special) {
                Write-Verbose "Skipping system special profile: $($profile.LocalPath)"
                continue
            }

            # Skip currently loaded/logged-in profiles
            if ($profile.Loaded) {
                Write-Verbose "Skipping currently loaded profile: $($profile.LocalPath)"
                continue
            }

            # Skip Default or Public folders
            if ($profile.LocalPath -like "*\Default" -or $profile.LocalPath -like "*\Public") {
                Write-Verbose "Skipping default/public profile: $($profile.LocalPath)"
                continue
            }

            # If LastUseTime is null, fallback to the directory last write time
            $lastUsed = $profile.LastUseTime
            if ($null -eq $lastUsed -and (Test-Path -Path $profile.LocalPath)) {
                $lastUsed = (Get-Item -Path $profile.LocalPath).LastWriteTime
            }

            if ($null -eq $lastUsed) {
                Write-Verbose "Skipping profile with no LastUseTime or path: $($profile.LocalPath)"
                continue
            }

            if ($lastUsed -lt $thresholdDate) {
                $status = "Pending Deletion"
                
                if ($PSCmdlet.ShouldProcess($profile.LocalPath, "Delete user profile (SID: $($profile.SID))")) {
                    try {
                        # Delete the profile using CIM method (cleanest and official way)
                        Remove-CimInstance -CimInstance $profile -ErrorAction Stop
                        $status = "Deleted Successfully"
                    }
                    catch {
                        $status = "Deletion Failed: $_"
                        Write-Error "Failed to delete profile $($profile.LocalPath): $_"
                    }
                }

                $results += [PSCustomObject]@{
                    SID        = $profile.SID
                    LocalPath  = $profile.LocalPath
                    LastUsed   = $lastUsed
                    Status     = $status
                }
            }
        }

        if ($results.Count -eq 0) {
            Write-Verbose "No inactive profiles found older than $Days days ($thresholdDate)."
        } else {
            Write-Output $results
        }
    }
    catch {
        Write-Error $_
        throw
    }
}
