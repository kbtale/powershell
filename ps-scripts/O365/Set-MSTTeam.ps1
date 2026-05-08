#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Updates properties of a team
.DESCRIPTION
    Updates properties of an existing Microsoft Team. Supports display name, description, visibility, and various member permission settings.
.PARAMETER GroupId
    GroupId of the team
.PARAMETER DisplayName
    Team display name
.PARAMETER Description
    Team description
.PARAMETER MailNickName
    Alias for the associated Office 365 Group
.PARAMETER Visibility
    Set to Public or Private
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
.EXAMPLE
    PS> ./Set-MSTTeam.ps1 -GroupId "group-id" -DisplayName "New Name" -Visibility "Private"
.EXAMPLE
    PS> ./Set-MSTTeam.ps1 -GroupId "group-id" -AllowGiphy $false -AllowStickersAndMemes $false
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [ValidateLength(5, 256)]
    [string]$DisplayName,
    [ValidateLength(0, 1024)]
    [string]$Description,
    [string]$MailNickName,
    [ValidateSet('Public', 'Private')]
    [string]$Visibility,
    [bool]$AllowAddRemoveApps,
    [bool]$AllowChannelMentions,
    [bool]$AllowCreateUpdateChannels,
    [bool]$AllowCreateUpdateRemoveConnectors,
    [bool]$AllowCreateUpdateRemoveTabs,
    [bool]$AllowCustomMemes,
    [bool]$AllowDeleteChannels,
    [bool]$AllowGiphy,
    [bool]$AllowGuestCreateUpdateChannels,
    [bool]$AllowGuestDeleteChannels,
    [bool]$AllowOwnerDeleteMessages,
    [bool]$AllowStickersAndMemes,
    [bool]$AllowTeamMentions,
    [bool]$AllowUserDeleteMessages,
    [bool]$AllowUserEditMessages,
    [ValidateSet('Strict', 'Moderate')]
    [string]$GiphyContentRating,
    [bool]$ShowInTeamsSearchAndSuggestions
)

Process {
    try {
        [string[]]$Properties = @('DisplayName', 'GroupId')
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId}

        if (-not [System.String]::IsNullOrWhiteSpace($DisplayName)) {
            $cmdArgs.Add('DisplayName', $DisplayName)
        }
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

        $boolParams = @('AllowAddRemoveApps', 'AllowChannelMentions', 'AllowCreateUpdateChannels', 'AllowCreateUpdateRemoveConnectors', 'AllowCreateUpdateRemoveTabs', 'AllowCustomMemes', 'AllowDeleteChannels', 'AllowGiphy', 'AllowGuestCreateUpdateChannels', 'AllowGuestDeleteChannels', 'AllowOwnerDeleteMessages', 'AllowStickersAndMemes', 'AllowTeamMentions', 'AllowUserDeleteMessages', 'AllowUserEditMessages', 'ShowInTeamsSearchAndSuggestions')
        foreach ($paramName in $boolParams) {
            if ($PSBoundParameters.ContainsKey($paramName)) {
                $cmdArgs.Add($paramName, (Get-Variable -Name $paramName -ValueOnly))
            }
        }

        $result = Set-Team @cmdArgs | Select-Object $Properties

        if ($null -eq $result) {
            Write-Output "Team properties updated"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
