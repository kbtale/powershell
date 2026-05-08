#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Creates a new Team with O365 Unified Group
.DESCRIPTION
    Creates a new Team in Microsoft Teams backed by an O365 Unified Group. Supports optional user and channel creation during provisioning.
.PARAMETER DisplayName
    Team display name
.PARAMETER Description
    Team description
.PARAMETER Visibility
    Set to Public or Private
.PARAMETER MailNickName
    Alias for the associated Office 365 Group, must be unique across the tenant
.PARAMETER AllowAddRemoveApps
    Members can add apps to the team
.PARAMETER AllowChannelMentions
    Channels can be @ mentioned
.PARAMETER AllowCreateUpdateChannels
    Members can create channels
.PARAMETER AllowCreateUpdateRemoveConnectors
    Members can manage connectors
.PARAMETER AllowCreateUpdateRemoveTabs
    Members can manage tabs in channels
.PARAMETER AllowCustomMemes
    Members can use custom memes
.PARAMETER AllowDeleteChannels
    Members can delete channels
.PARAMETER AllowGuestCreateUpdateChannels
    Guests can create channels
.PARAMETER AllowGiphy
    Giphy can be used in the team
.PARAMETER AllowGuestDeleteChannels
    Guests can delete channels
.PARAMETER AllowOwnerDeleteMessages
    Owners can delete any messages
.PARAMETER AllowStickersAndMemes
    Stickers and memes usage is allowed
.PARAMETER AllowTeamMentions
    The entire team can be @ mentioned
.PARAMETER AllowUserDeleteMessages
    Members can delete their own messages
.PARAMETER AllowUserEditMessages
    Users can edit their messages
.PARAMETER ShowInTeamsSearchAndSuggestions
    Private teams are searchable from Teams clients
.PARAMETER GiphyContentRating
    Sensitivity level of giphy usage
.PARAMETER Owner
    Desired owner of the group
.PARAMETER Users
    One or more User UPNs to add as members
.PARAMETER Channels
    One or more channel display names, comma separated
.PARAMETER RetainCreatedGroup
    Retain the group if team creation fails
.EXAMPLE
    PS> ./New-MSTTeam.ps1 -DisplayName "Project Team" -Visibility "Private"
.EXAMPLE
    PS> ./New-MSTTeam.ps1 -DisplayName "Engineering" -Description "Engineering team" -Owner "lead@domain.com" -Users @("dev1@domain.com","dev2@domain.com") -Channels "General,Support"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateLength(5, 256)]
    [string]$DisplayName,
    [ValidateLength(0, 1024)]
    [string]$Description,
    [ValidateSet('Public', 'Private')]
    [string]$Visibility,
    [string]$MailNickName,
    [bool]$AllowAddRemoveApps,
    [bool]$AllowChannelMentions,
    [bool]$AllowCreateUpdateChannels,
    [bool]$AllowCreateUpdateRemoveConnectors,
    [bool]$AllowCreateUpdateRemoveTabs,
    [bool]$AllowCustomMemes,
    [bool]$AllowDeleteChannels,
    [bool]$AllowGuestCreateUpdateChannels,
    [bool]$AllowGiphy,
    [bool]$AllowGuestDeleteChannels,
    [bool]$AllowOwnerDeleteMessages,
    [bool]$AllowStickersAndMemes,
    [bool]$AllowTeamMentions,
    [bool]$AllowUserDeleteMessages,
    [bool]$AllowUserEditMessages,
    [bool]$ShowInTeamsSearchAndSuggestions,
    [ValidateSet('Strict', 'Moderate')]
    [string]$GiphyContentRating,
    [string]$Owner,
    [string[]]$Users,
    [string]$Channels,
    [switch]$RetainCreatedGroup
)

Process {
    try {
        [string[]]$Properties = @('DisplayName', 'GroupId')
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'DisplayName' = $DisplayName}

        if (-not [System.String]::IsNullOrWhiteSpace($Description)) {
            $cmdArgs.Add('Description', $Description)
            $Properties += 'Description'
        }
        if (-not [System.String]::IsNullOrWhiteSpace($MailNickName)) {
            $cmdArgs.Add('MailNickName', $MailNickName)
            $Properties += 'MailNickName'
        }
        if (-not [System.String]::IsNullOrWhiteSpace($Visibility)) {
            $cmdArgs.Add('Visibility', $Visibility)
            $Properties += 'Visibility'
        }
        if (-not [System.String]::IsNullOrWhiteSpace($GiphyContentRating)) {
            $cmdArgs.Add('GiphyContentRating', $GiphyContentRating)
            $Properties += 'GiphyContentRating'
        }
        if (-not [System.String]::IsNullOrWhiteSpace($Owner)) {
            $cmdArgs.Add('Owner', $Owner)
            $Properties += 'Owner'
        }

        $boolParams = @('AllowAddRemoveApps', 'AllowChannelMentions', 'AllowCreateUpdateChannels', 'AllowCreateUpdateRemoveConnectors', 'AllowCreateUpdateRemoveTabs', 'AllowCustomMemes', 'AllowDeleteChannels', 'AllowGuestCreateUpdateChannels', 'AllowGiphy', 'AllowGuestDeleteChannels', 'AllowOwnerDeleteMessages', 'AllowStickersAndMemes', 'AllowTeamMentions', 'AllowUserDeleteMessages', 'AllowUserEditMessages', 'ShowInTeamsSearchAndSuggestions')
        foreach ($paramName in $boolParams) {
            if ($PSBoundParameters.ContainsKey($paramName)) {
                $cmdArgs.Add($paramName, (Get-Variable -Name $paramName -ValueOnly))
            }
        }

        $cmdArgs.Add('RetainCreatedGroup', $RetainCreatedGroup)
        $team = New-Team @cmdArgs | Select-Object $Properties

        $result = @()
        $result += $team

        if (($null -ne $Users) -and ($Users.Length -gt 0)) {
            foreach ($usr in $Users) {
                try {
                    $null = Add-TeamUser -User $usr -GroupId $team.GroupId -Role Member -ErrorAction Stop
                    $result += "User $($usr) added to team $($team.DisplayName)"
                }
                catch {
                    $result += "Error adding user $($usr) to team $($team.DisplayName)"
                }
            }
        }

        if (($null -ne $Channels) -and ($Channels.Length -gt 0)) {
            foreach ($cnl in $Channels.Split(',')) {
                try {
                    $null = New-TeamChannel -GroupId $team.GroupId -DisplayName $cnl.Trim() -ErrorAction Stop
                    $result += "Channel $($cnl.Trim()) added to team $($team.DisplayName)"
                }
                catch {
                    $result += "Error adding channel $($cnl.Trim()) to team $($team.DisplayName)"
                }
            }
        }

        foreach ($item in $result) {
            if ($item -is [PSCustomObject]) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
            }
            else {
                [PSCustomObject]@{
                    Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                    Result    = $item
                }
            }
        }
    }
    catch { throw }
}
