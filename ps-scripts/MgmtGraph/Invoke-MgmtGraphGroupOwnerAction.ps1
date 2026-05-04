#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Manages owner actions for a Microsoft Graph group

.DESCRIPTION
    Adds or removes owners (Users or Service Principals) from a specifies Microsoft Graph group.

.PARAMETER Identity
    Specifies the ID of the group to manage.

.PARAMETER AddOwner
    Optional. Specifies an array of User or Service Principal IDs to add as owners.

.PARAMETER RemoveOwner
    Optional. Specifies an array of User or Service Principal IDs to remove from ownership.

.EXAMPLE
    PS> ./Invoke-MgmtGraphGroupOwnerAction.ps1 -Identity "group-id" -AddOwner "user-id-1"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string[]]$AddOwner,

    [string[]]$RemoveOwner
)

Process {
    try {
        # Handle Additions
        foreach ($id in $AddOwner) {
            $params = @{
                'GroupId'          = $Identity
                'OdataId'          = "https://graph.microsoft.com/v1.0/directoryObjects/$id"
                'Confirm'          = $false
                'ErrorAction'      = 'Stop'
            }
            New-MgGroupOwnerByRef @params
        }

        # Handle Removals
        foreach ($id in $RemoveOwner) {
            $params = @{
                'GroupId'          = $Identity
                'DirectoryObjectId' = $id
                'Confirm'          = $false
                'ErrorAction'      = 'Stop'
            }
            Remove-MgGroupOwnerByRef @params
        }

        $result = [PSCustomObject]@{
            GroupId      = $Identity
            AddedCount   = ($AddOwner | Measure-Object).Count
            RemovedCount = ($RemoveOwner | Measure-Object).Count
            Action       = "GroupOwnerActionExecuted"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
