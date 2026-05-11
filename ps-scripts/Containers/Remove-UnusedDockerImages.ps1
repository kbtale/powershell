#Requires -Version 5.1

<#
.SYNOPSIS
    Containers: Purges unused Docker images, dangling volumes, and stopped containers
.DESCRIPTION
    Reclaims storage by cleaning up dangling image layers, stopped containers, unused networks, and optionally unused volumes on the system.
.PARAMETER PruneVolumes
    Prune unused named data volumes as well (caution: could delete persistent data if no active container binds it).
.PARAMETER Force
    Bypasses the confirmation prompt.
.EXAMPLE
    PS> ./Remove-UnusedDockerImages.ps1 -PruneVolumes -Force
.CATEGORY Containers
#>

[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [switch]$PruneVolumes,

    [switch]$Force
)

Process {
    try {
        if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
            Write-Warning "Docker CLI is not installed or not found in the system's PATH. Please install Docker and try again."
            return
        }

        $pruneArgs = @('system', 'prune')
        if ($PruneVolumes) {
            $pruneArgs += '--volumes'
        }
        if ($Force -or $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')) {
            $pruneArgs += '--force'
        }

        $desc = "Cleans up dangling Docker resources (Prune Volumes = $PruneVolumes)"
        if ($PSCmdlet.ShouldProcess("Docker Host Environment", "Prune system data. This cannot be undone. " + $desc)) {
            Write-Host "Initiating Docker system prune..." -ForegroundColor Cyan
            
            $output = docker @pruneArgs 2>&1
            
            Write-Host "Prune operation successfully finalized!" -ForegroundColor Green
            Write-Output $output
        }
    }
    catch {
        Write-Error $_
        throw
    }
}
