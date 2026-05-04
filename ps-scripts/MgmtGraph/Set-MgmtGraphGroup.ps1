#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Updates Microsoft Graph group properties

.DESCRIPTION
    Updates properties for an existing Microsoft Graph group, such as display name, description, or visibility.

.PARAMETER Identity
    Specifies the ID of the group to update.

.PARAMETER DisplayName
    Optional. Specifies the new display name.

.PARAMETER Description
    Optional. Specifies the new description.

.PARAMETER Visibility
    Optional. Specifies the new visibility level (Public, Private).

.PARAMETER MailNickname
    Optional. Specifies the new mail alias.

.EXAMPLE
    PS> ./Set-MgmtGraphGroup.ps1 -Identity "86c75b0a-..." -Description "Updated team description"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string]$DisplayName,

    [string]$Description,

    [ValidateSet('Public', 'Private')]
    [string]$Visibility,

    [string]$MailNickname
)

Process {
    try {
        $params = @{
            'GroupId'     = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('DisplayName')) { $params.Add('DisplayName', $DisplayName) }
        if ($PSBoundParameters.ContainsKey('Description')) { $params.Add('Description', $Description) }
        if ($PSBoundParameters.ContainsKey('Visibility')) { $params.Add('Visibility', $Visibility) }
        if ($PSBoundParameters.ContainsKey('MailNickname')) { $params.Add('MailNickname', $MailNickname) }

        if ($params.Count -gt 3) {
            Update-MgGroup @params
            
            $result = [PSCustomObject]@{
                GroupId   = $Identity
                Action    = "GroupUpdated"
                Status    = "Success"
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
        else {
            Write-Warning "No properties specified to update for group '$Identity'."
        }
    }
    catch {
        throw
    }
}
