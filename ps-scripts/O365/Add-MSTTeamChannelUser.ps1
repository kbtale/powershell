#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Adds an owner or member to a private channel
.DESCRIPTION
    Adds a user as owner or member to a private channel in Microsoft Teams.
.PARAMETER GroupId
    GroupId of the parent team
.PARAMETER DisplayName
    Display name of the private channel
.PARAMETER User
    User's UPN to add to the channel
.PARAMETER Role
    User's role in the channel (Owner)
.EXAMPLE
    PS> ./Add-MSTTeamChannelUser.ps1 -GroupId "group-id" -DisplayName "Private Channel" -User "user@domain.com"
.EXAMPLE
    PS> ./Add-MSTTeamChannelUser.ps1 -GroupId "group-id" -DisplayName "Private Channel" -User "user@domain.com" -Role "Owner"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [Parameter(Mandatory = $true)]
    [string]$User,
    [ValidateSet('Owner')]
    [string]$Role
)

Process {
    try {
        [string[]]$Properties = @('Name', 'User', 'Role', 'UserID')
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId; 'User' = $User; 'DisplayName' = $DisplayName}

        if (-not [System.String]::IsNullOrWhiteSpace($Role)) {
            $cmdArgs.Add('Role', $Role)
        }
        $null = Add-TeamChannelUser @cmdArgs
        $result = Get-TeamChannelUser -GroupId $GroupId -DisplayName $DisplayName -ErrorAction Stop | Sort-Object Name | Select-Object $Properties

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No channel users found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
