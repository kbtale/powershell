#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Creates a new open extension on a group

.DESCRIPTION
    Creates a new custom open schema extension on a specified group in Microsoft Graph, allowing application-specific properties to be stored.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER Id
    The unique identifier (name) of the open extension.

.EXAMPLE
    PS> ./New-MgmtGraphGroupExtension.ps1 -GroupId "group-id-123" -Id "MyCustomExtension"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Id
)

Process {
    try {
        $params = @{
            'GroupId'     = $GroupId
            'Id'          = $Id
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        $ext = New-MgGroupExtension @params

        $result = [PSCustomObject]@{
            GroupId     = $GroupId
            ExtensionId = $ext.Id
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
