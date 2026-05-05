#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Audits tenant organization details

.DESCRIPTION
    Retrieves the organization properties for the current Microsoft Graph tenant, including tenant ID, display name, and technical contact details.

.PARAMETER Identity
    Optional. Specifies the ID of the organization to retrieve. If omitted, all organizations (typically just one) are returned.

.EXAMPLE
    PS> ./Get-MgmtGraphOrganization.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Position = 0)]
    [string]$Identity
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }

        if ($Identity) {
            $params.Add('OrganizationId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $orgs = Get-MgOrganization @params
        
        $results = foreach ($o in $orgs) {
            [PSCustomObject]@{
                DisplayName         = $o.DisplayName
                Id                  = $o.Id
                TenantType          = $o.TenantType
                Country             = $o.Country
                CreatedDateTime     = $o.CreatedDateTime
                OnPremisesSyncEnabled = $o.OnPremisesSyncEnabled
                Timestamp           = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
