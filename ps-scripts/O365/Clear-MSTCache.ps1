#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Clears the Microsoft Teams client cache
.DESCRIPTION
    Clears the Microsoft Teams client cache on a local or remote computer. Optionally stops the Teams process before clearing.
.PARAMETER ComputerName
    Specifies the computer on which the cache is cleared. Defaults to the local computer.
.PARAMETER AccessAccount
    Specifies a user account that has permission to perform this action on the remote computer
.PARAMETER StopTeamsProcess
    Stop Microsoft Teams process before cleaning the cache
.EXAMPLE
    PS> ./Clear-MSTCache.ps1
.EXAMPLE
    PS> ./Clear-MSTCache.ps1 -ComputerName "PC01" -StopTeamsProcess
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$ComputerName,
    [pscredential]$AccessAccount,
    [switch]$StopTeamsProcess
)

Process {
    try {
        [string[]]$AppDataLocations = @(
            '\Microsoft\teams\application cache\cache',
            '\Microsoft\teams\blob_storage',
            '\Microsoft\teams\databases',
            '\Microsoft\teams\cache',
            '\Microsoft\teams\gpucache',
            '\Microsoft\teams\Indexeddb',
            '\Microsoft\teams\Local Storage',
            '\Microsoft\teams\tmp'
        )

        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) {
            $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
        }

        [hashtable]$invArgs = @{'ErrorAction' = 'Stop'; 'ComputerName' = $ComputerName}
        if ($null -ne $AccessAccount) {
            $invArgs.Add('Credential', $AccessAccount)
        }

        if ($StopTeamsProcess) {
            try {
                Invoke-Command @invArgs -ScriptBlock {
                    Get-Process -ProcessName Teams -ErrorAction SilentlyContinue | Stop-Process -Force
                    Start-Sleep -Seconds 5
                }
                Write-Output "Microsoft Teams process stopped"
            }
            catch {
                Write-Output "Error stopping Microsoft Teams process: $($_.Exception.Message)"
            }
        }

        Invoke-Command @invArgs -ScriptBlock {
            foreach ($fol in $Using:AppDataLocations) {
                $path = "$($env:APPDATA)$($fol)"
                if (Test-Path -Path $path) {
                    $null = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Remove-Item -Confirm:$false -Recurse
                }
            }
        }

        [PSCustomObject]@{
            Timestamp    = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            ComputerName = $ComputerName
            Status       = "Microsoft Teams client cache on $ComputerName cleared"
        }
    }
    catch { throw }
}
