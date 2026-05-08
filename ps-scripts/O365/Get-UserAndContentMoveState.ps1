#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets user and content move state
.DESCRIPTION
    Checks the status of a user or site move across geo locations.
.PARAMETER UserPrincipalName
    User principal name to check move state
.PARAMETER OdbMoveId
    OneDrive GUID MoveID for the job
.PARAMETER MoveDirection
    Direction of the user move
.PARAMETER MoveState
    Current move state status
.PARAMETER MoveStartTime
    Filter moves scheduled to begin at a particular time
.PARAMETER MoveEndTime
    Filter moves scheduled to end by a particular time
.EXAMPLE
    PS> ./Get-UserAndContentMoveState.ps1 -UserPrincipalName "user@contoso.com"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = 'User')]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'User')]
    [string]$UserPrincipalName,
    [Parameter(Mandatory = $true, ParameterSetName = 'OdbMove')]
    [string]$OdbMoveId,
    [Parameter(ParameterSetName = 'MoveReport')]
    [ValidateSet('All','MoveIn','MoveOut')]
    [string]$MoveDirection,
    [Parameter(ParameterSetName = 'MoveReport')]
    [ValidateSet('All','NotStarted','Scheduled','InProgress','Stopped','Success','Failed')]
    [string]$MoveState,
    [Parameter(ParameterSetName = 'MoveReport')]
    [datetime]$MoveEndTime,
    [Parameter(ParameterSetName = 'MoveReport')]
    [datetime]$MoveStartTime
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop' }
        if ($PSCmdlet.ParameterSetName -eq 'OdbMove') { $cmdArgs.Add('OdbMoveId', $OdbMoveId) }
        elseif ($PSCmdlet.ParameterSetName -eq 'User') { $cmdArgs.Add('UserPrincipalName', $UserPrincipalName) }
        if ($PSBoundParameters.ContainsKey('MoveDirection')) { $cmdArgs.Add('MoveDirection', $MoveDirection) }
        if ($PSBoundParameters.ContainsKey('MoveState')) { $cmdArgs.Add('MoveState', $MoveState) }
        if ($PSBoundParameters.ContainsKey('MoveEndTime')) { $cmdArgs.Add('MoveEndTime', $MoveEndTime) }
        if ($PSBoundParameters.ContainsKey('MoveStartTime')) { $cmdArgs.Add('MoveStartTime', $MoveStartTime) }
        $result = Get-SPOUserAndContentMoveState @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}