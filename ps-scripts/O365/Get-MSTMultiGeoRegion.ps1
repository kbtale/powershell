#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get multi-geo region for users or groups
.DESCRIPTION
    Retrieves the multi-geo region assignment for a specified user or group.
.PARAMETER ObjectId
    Group or user ID
.PARAMETER ObjectType
    Specify whether the object is a Group or User
.EXAMPLE
    PS> ./Get-MSTMultiGeoRegion.ps1 -ObjectId "object-id" -ObjectType "User"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ObjectId,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Group', 'User')]
    [string]$ObjectType
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'EntityId' = $ObjectId; 'EntityType' = $ObjectType}

        $result = Get-MultiGeoRegion @cmdArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "No multi-geo region found"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
