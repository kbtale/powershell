#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of users of a channel
.DESCRIPTION
    Generates an HTML report with the users assigned to a private channel.
.PARAMETER GroupId
    GroupId of the parent team
.PARAMETER DisplayName
    Display name of the private channel
.PARAMETER Role
    Filter results to only users with the given role
.EXAMPLE
    PS> ./Get-MSTTeamChannelUser-Html.ps1 -GroupId "group-id" -DisplayName "Private Channel" | Out-File report.html
.EXAMPLE
    PS> ./Get-MSTTeamChannelUser-Html.ps1 -GroupId "group-id" -DisplayName "Private Channel" -Role "Owner" | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [ValidateSet('Member','Owner','Guest')]
    [string]$Role
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId; 'DisplayName' = $DisplayName}
        if (-not [System.String]::IsNullOrWhiteSpace($Role)) {
            $cmdArgs.Add('Role', $Role)
        }

        $result = Get-TeamChannelUser @cmdArgs | Sort-Object Name | Select-Object Name, User, Role, UserID

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No channel users found"
            return
        }

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
