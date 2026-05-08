#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Set team targeting hierarchy
.DESCRIPTION
    Sets the team targeting hierarchy from a CSV file.
.PARAMETER FilePath
    Path to the CSV file containing the hierarchy definition
.EXAMPLE
    PS> ./Set-MSTTeamTargetingHierarchy.ps1 -FilePath "C:\data\hierarchy.csv"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'; 'FilePath' = $FilePath}

        $result = Set-TeamTargetingHierarchy @getArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "Team targeting hierarchy set"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
