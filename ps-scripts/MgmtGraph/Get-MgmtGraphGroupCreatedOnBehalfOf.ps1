#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves the creator of a group

.DESCRIPTION
    Retrieves the user, application, or service principal that created the specifies group on behalf of the tenant from Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupCreatedOnBehalfOf.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId
)

Process {
    try {
        $creator = Get-MgGroupCreatedOnBehalfOf -GroupId $GroupId -ErrorAction Stop
        
        $results = foreach ($c in $creator) {
            $displayName = $c.AdditionalProperties['displayName']
            if ($null -eq $displayName) { $displayName = $c.DisplayName }

            $upn = $c.AdditionalProperties['userPrincipalName']
            if ($null -eq $upn) { $upn = $c.Mail }

            $type = $c.AdditionalProperties['@odata.type']
            if ($type) { $type = $type -replace '^#microsoft.graph.', '' }

            [PSCustomObject]@{
                GroupId           = $GroupId
                CreatorId         = $c.Id
                DisplayName       = $displayName
                UserPrincipalName = $upn
                Type              = $type
                Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
