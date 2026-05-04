#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Updates Microsoft Graph user account properties

.DESCRIPTION
    Updates properties for an existing Microsoft Graph user account, such as display name, job title, department, or account status.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to update.

.PARAMETER DisplayName
    Optional. Specifies the new display name.

.PARAMETER JobTitle
    Optional. Specifies the new job title.

.PARAMETER Department
    Optional. Specifies the new department.

.PARAMETER AccountEnabled
    Optional. Specifies whether the account is enabled ($true) or disabled ($false).

.EXAMPLE
    PS> ./Set-MgmtGraphUser.ps1 -Identity "bob@example.com" -JobTitle "Senior Engineer"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string]$DisplayName,

    [string]$JobTitle,

    [string]$Department,

    [bool]$AccountEnabled
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('DisplayName')) { $params.Add('DisplayName', $DisplayName) }
        if ($PSBoundParameters.ContainsKey('JobTitle')) { $params.Add('JobTitle', $JobTitle) }
        if ($PSBoundParameters.ContainsKey('Department')) { $params.Add('Department', $Department) }
        if ($PSBoundParameters.ContainsKey('AccountEnabled')) { $params.Add('AccountEnabled', $AccountEnabled) }

        if ($params.Count -gt 3) {
            Update-MgUser @params
            
            $result = [PSCustomObject]@{
                Identity  = $Identity
                Action    = "UserUpdated"
                Status    = "Success"
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
        else {
            Write-Warning "No properties specified to update for user '$Identity'."
        }
    }
    catch {
        throw
    }
}
