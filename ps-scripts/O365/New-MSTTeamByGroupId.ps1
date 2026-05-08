#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Creates a new Team from existing O365 Unified Group
.DESCRIPTION
    Creates a new Team in Microsoft Teams using an existing O365 Unified Group.
.PARAMETER GroupId
    Specify a GroupId to convert to a Team
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
    Desired owner of the team
.EXAMPLE
    PS> ./New-MSTTeamByGroupId.ps1 -GroupId "group-id"
.EXAMPLE
    PS> ./New-MSTTeamByGroupId.ps1 -GroupId "group-id" -Owner "admin@domain.com" -AllowGiphy $true
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
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
    [string]$Owner
)

Process {
    try {
        [string[]]$Properties = @('DisplayName', 'GroupId')
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId}

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

        $result = New-Team @cmdArgs | Select-Object $Properties

        if ($null -eq $result) {
            Write-Output "Failed to create team from group"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
