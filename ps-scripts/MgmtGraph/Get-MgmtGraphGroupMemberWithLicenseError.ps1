#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves group members with licensing errors

.DESCRIPTION
    Retrieves the members of a group who have license assignment errors, with optional member-type filtering, from Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ResultType
    Optional. The type of group members to retrieve. Supported values: AsApplication, AsDevice, AsGroup, AsOrgContact, AsServicePrincipal, AsUser.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupMemberWithLicenseError.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [ValidateSet('AsApplication', 'AsDevice', 'AsGroup', 'AsOrgContact', 'AsServicePrincipal', 'AsUser')]
    [string]$ResultType
)

Process {
    try {
        $params = @{
            'GroupId'     = $GroupId
            'All'         = $true
            'ErrorAction' = 'Stop'
        }

        $mships = $null

        if ($ResultType) {
            switch ($ResultType) {
                'AsApplication' {
                    $mships = Get-MgGroupMemberWithLicenseErrorAsApplication @params
                }
                'AsDevice' {
                    $mships = Get-MgGroupMemberWithLicenseErrorAsDevice @params
                }
                'AsGroup' {
                    $mships = Get-MgGroupMemberWithLicenseErrorAsGroup @params
                }
                'AsOrgContact' {
                    $mships = Get-MgGroupMemberWithLicenseErrorAsOrgContact @params
                }
                'AsServicePrincipal' {
                    $mships = Get-MgGroupMemberWithLicenseErrorAsServicePrincipal @params
                }
                'AsUser' {
                    $mships = Get-MgGroupMemberWithLicenseErrorAsUser @params
                }
            }
        }
        else {
            $mships = Get-MgGroupMemberWithLicenseError @params
        }

        $results = foreach ($itm in $mships) {
            $displayName = $itm.AdditionalProperties['displayName']
            if ($null -eq $displayName) { $displayName = $itm.DisplayName }

            $mailNickname = $itm.AdditionalProperties['mailNickname']
            if ($null -eq $mailNickname) { $mailNickname = $itm.MailNickname }

            $type = $ResultType
            if (-not $type) { $type = $itm.AdditionalProperties['@odata.type'] -replace '^#microsoft.graph.', '' }

            [PSCustomObject]@{
                GroupId      = $GroupId
                MemberId     = $itm.Id
                DisplayName  = $displayName
                MailNickname = $mailNickname
                Type         = $type
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        $results = $results | Sort-Object DisplayName
        Write-Output $results
    }
    catch {
        throw
    }
}
