#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits group memberships for a Microsoft Graph user

.DESCRIPTION
    Retrieves the list of groups and directory roles that a specifies Microsoft Graph user is a member of. Supports both direct and transitive (nested) memberships.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to audit.

.PARAMETER Transitive
    If set, retrieves transitive memberships including nested groups.

.EXAMPLE
    PS> ./Get-MgmtGraphUserMemberOf.ps1 -Identity "user@example.com" -Transitive

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [switch]$Transitive
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'All'         = $true
            'ErrorAction' = 'Stop'
        }

        if ($Transitive) {
            $memberships = Get-MgUserTransitiveMemberOf @params
        }
        else {
            $memberships = Get-MgUserMemberOf @params
        }

        $results = foreach ($m in $memberships) {
            [PSCustomObject]@{
                DisplayName = $m.AdditionalProperties.displayName
                Type        = $m.AdditionalProperties.'@odata.type'.Replace('#microsoft.graph.', '')
                Mail        = $m.AdditionalProperties.mail
                Id          = $m.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
