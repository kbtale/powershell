#Requires -Version 5.1

<#
.SYNOPSIS
    Containers: Archives and backs up target Docker named volumes safely
.DESCRIPTION
    Backs up a local Docker volume by launching a temporary container to archive its contents. Can optionally suspend containers actively writing to the volume to guarantee file consistency.
.PARAMETER VolumeName
    The exact name of the target Docker volume to back up.
.PARAMETER BackupPath
    The directory on the host machine where the backup archive should be saved.
.PARAMETER Safe
    Temporarily stops any active containers utilizing the volume during backup, restarting them immediately after completion to prevent active write file lock/corruption.
.EXAMPLE
    PS> ./Backup-DockerVolume.ps1 -VolumeName "db_data" -BackupPath "C:\Backups" -Safe
.CATEGORY Containers
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VolumeName,

    [Parameter(Mandatory = $true)]
    [string]$BackupPath,

    [switch]$Safe
)

Process {
    try {
        if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
            Write-Warning "Docker CLI is not installed or not found in the PATH."
            return
        }

        $volumeCheck = docker volume ls --filter "name=^$($VolumeName)$" --format "{{.Name}}"
        if (-not $volumeCheck) {
            throw "Target Docker volume '$VolumeName' was not found."
        }

        $absoluteBackupPath = [System.IO.Path]::GetFullPath($BackupPath)
        if (-not (Test-Path -Path $absoluteBackupPath)) {
            New-Item -ItemType Directory -Path $absoluteBackupPath -Force | Out-Null
        }

        $backupFileName = "$VolumeName-$(Get-Date -Format 'yyyyMMdd_HHmmss').tar"
        
        $containers = docker ps -a --filter "volume=$VolumeName" --format "{{.ID}},{{.Names}},{{.State}}"
        $runningContainersToStop = @()

        if ($containers) {
            Write-Verbose "Located containers using volume '$VolumeName':"
            foreach ($c in $containers) {
                if ([string]::IsNullOrWhiteSpace($c)) { continue }
                $parts = $c.Split(',')
                $cId = $parts[0]
                $cName = $parts[1]
                $cState = $parts[2]

                Write-Verbose "  - $cName (ID: $cId) | State: $cState"

                if ($cState -eq 'running' -and $Safe) {
                    $runningContainersToStop += [PSCustomObject]@{ ID = $cId; Name = $cName }
                }
            }
        }

        if ($runningContainersToStop.Count -gt 0) {
            Write-Host "Suspending $($runningContainersToStop.Count) active container(s) to secure write consistency..." -ForegroundColor Yellow
            foreach ($container in $runningContainersToStop) {
                Write-Host "Stopping container '$($container.Name)'..." -ForegroundColor DarkYellow
                docker stop $($container.ID) | Out-Null
            }
        }

        try {
            Write-Host "Executing transaction backup of volume '$VolumeName'..." -ForegroundColor Cyan

            $linuxBackupPath = $absoluteBackupPath -replace '\\', '/'
            if ($linuxBackupPath -match '^([A-Za-z]):/(.*)') {
                $linuxBackupPath = "/" + $Matches[1].ToLower() + "/" + $Matches[2]
            }

            docker run --rm `
                -v "${VolumeName}:/volume_data_src:ro" `
                -v "${linuxBackupPath}:/backup_dest_dst" `
                alpine tar -cf "/backup_dest_dst/$backupFileName" -C /volume_data_src . | Out-Null

            Write-Host "Backup archived successfully at: $(Join-Path $absoluteBackupPath $backupFileName)" -ForegroundColor Green
        }
        finally {
            if ($runningContainersToStop.Count -gt 0) {
                Write-Host "Resuming suspended container(s)..." -ForegroundColor Yellow
                foreach ($container in $runningContainersToStop) {
                    Write-Host "Starting container '$($container.Name)'..." -ForegroundColor DarkYellow
                    docker start $($container.ID) | Out-Null
                }
                Write-Host "Containers resumed successfully." -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Error $_
        throw
    }
}
