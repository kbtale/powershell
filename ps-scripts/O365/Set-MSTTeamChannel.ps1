#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Update Team channel settings
.DESCRIPTION
    Updates settings for an existing channel in Microsoft Teams. Supports renaming and updating the description.
.PARAMETER GroupId
    GroupId of the team
.PARAMETER CurrentDisplayName
    Current channel name
.PARAMETER NewDisplayName
    New channel display name
.PARAMETER Description
    Updated channel description
.EXAMPLE
    PS> ./Set-MSTTeamChannel.ps1 -GroupId "group-id" -CurrentDisplayName "Old Name" -NewDisplayName "New Name"
.EXAMPLE
    PS> ./Set-MSTTeamChannel.ps1 -GroupId "group-id" -CurrentDisplayName "Channel" -Description "Updated description"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [ValidateLength(5, 50)]
    [string]$CurrentDisplayName,
    [ValidateLength(5, 50)]
    [string]$NewDisplayName,
    [ValidateLength(0, 1024)]
    [string]$Description
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId; 'CurrentDisplayName' = $CurrentDisplayName}

        if (-not [System.String]::IsNullOrWhiteSpace($Description)) {
            $cmdArgs.Add('Description', $Description)
        }
        if (-not [System.String]::IsNullOrWhiteSpace($NewDisplayName)) {
            $cmdArgs.Add('NewDisplayName', $NewDisplayName)
        }

        $result = Set-TeamChannel @cmdArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "Channel update completed"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
