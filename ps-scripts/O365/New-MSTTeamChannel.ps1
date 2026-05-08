#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Add a new channel to a team
.DESCRIPTION
    Creates a new channel in a Microsoft Team. Supports single channel creation with description or bulk creation of multiple comma-separated channels.
.PARAMETER GroupId
    GroupId of the team
.PARAMETER ChannelNames
    One or more channel display names, comma separated
.PARAMETER DisplayName
    Channel display name for single creation
.PARAMETER Description
    Channel description
.EXAMPLE
    PS> ./New-MSTTeamChannel.ps1 -GroupId "group-id" -DisplayName "New Channel"
.EXAMPLE
    PS> ./New-MSTTeamChannel.ps1 -GroupId "group-id" -ChannelNames "Channel1,Channel2"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Single')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Multi')]
    [string]$GroupId,
    [Parameter(Mandatory = $true, ParameterSetName = 'Multi')]
    [string]$ChannelNames,
    [Parameter(Mandatory = $true, ParameterSetName = 'Single')]
    [ValidateLength(5, 50)]
    [string]$DisplayName,
    [Parameter(ParameterSetName = 'Single')]
    [ValidateLength(0, 1024)]
    [string]$Description
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId}

        if ($PSCmdlet.ParameterSetName -eq 'Multi') {
            $team = Get-Team -GroupId $GroupId -ErrorAction Stop | Select-Object -ExpandProperty DisplayName
            $result = @()
            foreach ($cnl in $ChannelNames.Split(',')) {
                try {
                    $null = New-TeamChannel @cmdArgs -DisplayName $cnl.Trim()
                    $result += "Channel $($cnl.Trim()) added to team $($team)"
                }
                catch {
                    $result += "Error adding channel $($cnl.Trim()) to team $($team)"
                }
            }
            foreach ($msg in $result) {
                [PSCustomObject]@{
                    Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                    Result    = $msg
                }
            }
        }
        else {
            $cmdArgs.Add('DisplayName', $DisplayName)
            if (-not [System.String]::IsNullOrWhiteSpace($Description)) {
                $cmdArgs.Add('Description', $Description)
            }
            $result = New-TeamChannel @cmdArgs | Select-Object *
            if ($null -eq $result) {
                Write-Output "Failed to create channel"
                return
            }
            $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
