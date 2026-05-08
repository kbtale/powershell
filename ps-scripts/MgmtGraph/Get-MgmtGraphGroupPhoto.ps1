#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves group profile photo metadata

.DESCRIPTION
    Retrieves the metadata of a specified group's profile photo in Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupPhoto.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId
)

Process {
    try {
        $photo = Get-MgGroupPhoto -GroupId $GroupId -All -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            GroupId   = $GroupId
            PhotoId   = $photo.Id
            Height    = $photo.Height
            Width     = $photo.Width
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
