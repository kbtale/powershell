#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves the count of open extensions for a group

.DESCRIPTION
    Retrieves the total count of custom open data extensions defined on a specified Microsoft Graph group.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupExtensionCount.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId
)

Process {
    try {
        $count = Get-MgGroupExtensionCount -GroupId $GroupId -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            GroupId        = $GroupId
            ExtensionCount = $count
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
