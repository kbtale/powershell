#Requires -Version 5.1

<#
.SYNOPSIS
    User Management: Scans and reports sizes and last activity of local user profiles
.DESCRIPTION
    Scans Windows user profiles registered in the Registry to report folder path, SID, folder size on disk, and last logoff activity (using NTUSER.DAT write time).
.PARAMETER IncludeSystem
    Include special system-level profiles (such as LocalService, NetworkService, and SystemProfile)
.EXAMPLE
    PS> ./Get-LocalProfilesSize.ps1
.CATEGORY User Management
#>

[CmdletBinding()]
Param(
    [switch]$IncludeSystem
)

Process {
    try {
        $profileRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
        $sids = Get-ChildItem -Path $profileRegPath -ErrorAction Stop

        $results = @()
        foreach ($sid in $sids) {
            $sidValue = $sid.PSChildName
            $profilePath = Get-ItemPropertyValue -Path $sid.PSPath -Name "ProfileImagePath" -ErrorAction SilentlyContinue
            
            if (-not $profilePath) { continue }

            # Skip system profiles unless requested
            # System profiles are usually under C:\Windows or have SIDs like S-1-5-18, 19, 20
            $isSystem = ($profilePath -like "*\System32\*" -or $sidValue -like "S-1-5-18" -or $sidValue -like "S-1-5-19" -or $sidValue -like "S-1-5-20")
            if ($isSystem -and -not $IncludeSystem) {
                continue
            }

            $sizeInBytes = 0
            $sizeFormatted = '0 MB'
            $lastActivity = $null

            if (Test-Path -Path $profilePath) {
                # Quick scan of files to sum size
                $files = Get-ChildItem -Path $profilePath -Recurse -File -Force -ErrorAction SilentlyContinue
                if ($files) {
                    $sizeInBytes = ($files | Measure-Object -Property Length -Sum).Sum
                    if ($null -eq $sizeInBytes) { $sizeInBytes = 0 }
                    
                    if ($sizeInBytes -gt 1GB) {
                        $sizeFormatted = "{0:N2} GB" -f ($sizeInBytes / 1GB)
                    } else {
                        $sizeFormatted = "{0:N2} MB" -f ($sizeInBytes / 1MB)
                    }
                }

                # NTUSER.DAT write time represents last logoff/unload activity
                $ntUserDat = Join-Path $profilePath "NTUSER.DAT"
                if (Test-Path -Path $ntUserDat) {
                    $lastActivity = (Get-Item -Path $ntUserDat -Force).LastWriteTime
                } else {
                    $lastActivity = (Get-Item -Path $profilePath).LastWriteTime
                }
            } else {
                $sizeFormatted = 'Folder Not Found'
            }

            $results += [PSCustomObject]@{
                SID             = $sidValue
                ProfilePath     = $profilePath
                SizeInBytes     = $sizeInBytes
                SizeFormatted   = $sizeFormatted
                LastActivity    = $lastActivity
                IsSystemProfile = $isSystem
            }
        }

        Write-Output ($results | Sort-Object SizeInBytes -Descending)
    }
    catch {
        Write-Error $_
        throw
    }
}
