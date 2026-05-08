#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Creates a new app in the Teams tenant app store
.DESCRIPTION
    Creates a new app in the Teams tenant app store from a local app manifest zip file.
.PARAMETER AppPath
    The local path of the app manifest zip file
.PARAMETER DistributionMethod
    The type of app in Teams. For LOB apps use "organization"
.EXAMPLE
    PS> ./New-MSTTeamsApp.ps1 -AppPath "C:\temp\myapp.zip" -DistributionMethod "organization"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$AppPath,
    [Parameter(Mandatory = $true)]
    [ValidateSet('organization', 'global')]
    [string]$DistributionMethod = 'organization'
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Path' = $AppPath; 'DistributionMethod' = $DistributionMethod}

        $result = New-TeamsApp @cmdArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "Failed to create Teams app"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
