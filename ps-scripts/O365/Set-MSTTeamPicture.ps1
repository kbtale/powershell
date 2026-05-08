#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Update the picture of a team
.DESCRIPTION
    Updates the team picture with an image file (.png, .gif, .jpg, or .jpeg).
.PARAMETER GroupId
    GroupId of the team
.PARAMETER ImagePath
    File path of the image (.png, .gif, .jpg, or .jpeg)
.EXAMPLE
    PS> ./Set-MSTTeamPicture.ps1 -GroupId "group-id" -ImagePath "C:\images\team-logo.png"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [string]$ImagePath
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId; 'ImagePath' = $ImagePath}

        $null = Set-TeamPicture @cmdArgs

        [PSCustomObject]@{
            Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            GroupId   = $GroupId
            ImagePath = $ImagePath
            Status    = 'Team picture updated'
        }
    }
    catch { throw }
}
