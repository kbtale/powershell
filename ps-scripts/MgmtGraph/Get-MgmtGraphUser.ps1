#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits Microsoft Graph user accounts

.DESCRIPTION
    Retrieves properties for a specifies Microsoft Graph user or lists all users in the tenant with selected attributes.

.PARAMETER Identity
    Optional. Specifies the UserPrincipalName, DisplayName, or ID of the user to retrieve.

.PARAMETER Property
    Optional. Specifies the list of properties to retrieve. Defaults to a standard set of identity and status fields.

.EXAMPLE
    PS> ./Get-MgmtGraphUser.ps1 -Identity "john.doe@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Position = 0)]
    [string]$Identity,

    [string[]]$Property = @('DisplayName', 'Id', 'UserPrincipalName', 'Mail', 'Department', 'JobTitle', 'AccountEnabled', 'UserType')
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
            'Property'    = $Property
        }

        if ($Identity) {
            $user = Get-MgUser -UserId $Identity @params -ErrorAction SilentlyContinue
            if (-not $user) {
                $user = Get-MgUser -Filter "displayName eq '$Identity'" @params
            }
        }
        else {
            $params.Add('All', $true)
            $user = Get-MgUser @params
        }

        if (-not $user) {
            Write-Warning "User '$Identity' not found."
            return
        }

        $results = foreach ($u in $user) {
            $obj = [ordered]@{}
            foreach ($p in $Property) {
                $obj[$p] = $u.$p
            }
            [PSCustomObject]$obj
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
