#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits all properties of a specific Microsoft Graph user

.DESCRIPTION
    Retrieves the complete set of properties and attributes for a specifies Microsoft Graph user, including account status, directory metadata, and personal info.

.PARAMETER Identity
    Specifies the UserPrincipalName, DisplayName, or ID of the user to retrieve.

.EXAMPLE
    PS> ./Get-MgmtGraphUserDetail.ps1 -Identity "jane.smith@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $user = Get-MgUser -UserId $Identity -Property "*" -ErrorAction SilentlyContinue
        
        if (-not $user) {
            $user = Get-MgUser -Filter "displayName eq '$Identity'" -Property "*" -ErrorAction Stop
        }

        if (-not $user) {
            throw "User '$Identity' not found."
        }

        # Return the first match if multiple are found via display name
        $results = foreach ($u in $user) {
            $u | Select-Object *
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
