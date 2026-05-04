#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Manages membership actions for a Microsoft Graph group

.DESCRIPTION
    Adds or removes members (Users or Groups) from a specifies Microsoft Graph group.

.PARAMETER Identity
    Specifies the ID of the group to manage.

.PARAMETER AddMember
    Optional. Specifies an array of User or Group IDs to add as members.

.PARAMETER RemoveMember
    Optional. Specifies an array of User or Group IDs to remove from memberships.

.EXAMPLE
    PS> ./Invoke-MgmtGraphGroupMemberAction.ps1 -Identity "group-id" -AddMember "user-id-1", "user-id-2"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string[]]$AddMember,

    [string[]]$RemoveMember
)

Process {
    try {
        # Handle Additions
        foreach ($id in $AddMember) {
            $null = New-MgGroupMember -GroupId $Identity -DirectoryObjectId $id -ErrorAction Stop
        }

        # Handle Removals
        foreach ($id in $RemoveMember) {
            $null = Remove-MgGroupMemberByRef -GroupId $Identity -DirectoryObjectId $id -ErrorAction Stop
        }

        $result = [PSCustomObject]@{
            GroupId      = $Identity
            AddedCount   = ($AddMember | Measure-Object).Count
            RemovedCount = ($RemoveMember | Measure-Object).Count
            Action       = "GroupMemberActionExecuted"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
