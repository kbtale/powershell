#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Creates a new Microsoft Graph group

.DESCRIPTION
    Provisions a new group in the Microsoft Graph tenant. Supports Security groups, Microsoft 365 (Unified) groups, and mail-enabled groups.

.PARAMETER DisplayName
    Specifies the display name for the new group.

.PARAMETER MailNickname
    Specifies the mail alias for the group. Required for M365 and mail-enabled groups.

.PARAMETER Description
    Optional. Specifies a description for the group.

.PARAMETER SecurityEnabled
    If set, creates a security group.

.PARAMETER MailEnabled
    If set, creates a mail-enabled group.

.PARAMETER Visibility
    Specifies the visibility level of the group. Valid values: Public, Private.

.PARAMETER Microsoft365Group
    If set, creates a Microsoft 365 (Unified) group.

.EXAMPLE
    PS> ./New-MgmtGraphGroup.ps1 -DisplayName "Project Alpha" -MailNickname "projectalpha" -Microsoft365Group -Visibility "Private"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,

    [Parameter(Mandatory = $true)]
    [string]$MailNickname,

    [string]$Description,

    [switch]$SecurityEnabled,

    [switch]$MailEnabled,

    [ValidateSet('Public', 'Private')]
    [string]$Visibility = 'Public',

    [switch]$Microsoft365Group
)

Process {
    try {
        $params = @{
            'DisplayName'     = $DisplayName
            'MailNickname'    = $MailNickname
            'MailEnabled'     = $MailEnabled
            'SecurityEnabled' = $SecurityEnabled
            'Visibility'      = $Visibility
            'Confirm'         = $false
            'ErrorAction'     = 'Stop'
        }

        if ($Description) { $params.Add('Description', $Description) }
        
        if ($Microsoft365Group) {
            $params.Add('GroupTypes', @('Unified'))
        }

        $group = New-MgGroup @params
        
        $result = [PSCustomObject]@{
            DisplayName     = $group.DisplayName
            Id              = $group.Id
            Mail            = $group.Mail
            SecurityEnabled = $group.SecurityEnabled
            MailEnabled     = $group.MailEnabled
            Visibility      = $group.Visibility
            Status          = "GroupCreated"
            Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
