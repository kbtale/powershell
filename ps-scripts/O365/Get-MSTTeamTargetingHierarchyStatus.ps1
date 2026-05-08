#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get team targeting hierarchy status
.DESCRIPTION
    Retrieves the status of the team targeting hierarchy. Supports filtering by an optional RequestID.
.PARAMETER RequestID
    Optional request ID to check a specific targeting hierarchy operation
.EXAMPLE
    PS> ./Get-MSTTeamTargetingHierarchyStatus.ps1
.EXAMPLE
    PS> ./Get-MSTTeamTargetingHierarchyStatus.ps1 -RequestID "request-guid"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$RequestID
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}

        if (-not [System.String]::IsNullOrWhiteSpace($RequestID)) {
            $cmdArgs.Add('RequestID', $RequestID)
        }

        $result = Get-TeamTargetingHierarchyStatus @cmdArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "No targeting hierarchy status found"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
