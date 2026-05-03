#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Reports logical disk usage and free space

.DESCRIPTION
    Retrieves information about logical disks on a local or remote computer, including total size, free space, and usage percentage. This script is useful for monitoring disk health and capacity planning.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER DriveLetter
    Specifies a specific drive letter (e.g., "C:") to query. If omitted, all logical disks are retrieved.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-DiskUsage.ps1 -ComputerName "FILESRV01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$DriveLetter,

    [pscredential]$Credential
)

Process
{
    try
    {
        $session = $null
        $cimParams = @{
            'ClassName'   = 'Win32_LogicalDisk'
            'Filter'      = "DriveType = 3" # Local Disks only
            'ErrorAction' = 'Stop'
        }

        if (-not [string]::IsNullOrWhiteSpace($DriveLetter))
        {
            $cimParams.Filter += " AND DeviceID = '$DriveLetter'"
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

        $disks = Get-CimInstance @cimParams

        $results = foreach ($disk in $disks)
        {
            $totalGB = [math]::Round($disk.Size / 1GB, 2)
            $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
            $usedGB = [math]::Round($totalGB - $freeGB, 2)
            $percentFree = [math]::Round(($freeGB / $totalGB) * 100, 2)

            [PSCustomObject]@{
                Drive        = $disk.DeviceID
                VolumeName   = $disk.VolumeName
                TotalGB      = $totalGB
                UsedGB       = $usedGB
                FreeGB       = $freeGB
                PercentFree  = $percentFree
                ComputerName = $ComputerName
            }
        }

        Write-Output $results
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
