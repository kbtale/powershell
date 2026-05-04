#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Audits Microsoft Graph groups

.DESCRIPTION
    Retrieves properties for a specifies Microsoft Graph group or lists all groups in the tenant with selected attributes.

.PARAMETER Identity
    Optional. Specifies the DisplayName or ID of the group to retrieve.

.PARAMETER Property
    Optional. Specifies the list of properties to retrieve. Defaults to a standard set of identity and status fields.

.EXAMPLE
    PS> ./Get-MgmtGraphGroup.ps1 -Identity "Sales Team"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Position = 0)]
    [string]$Identity,

    [string[]]$Property = @('DisplayName', 'Id', 'Description', 'GroupTypes', 'Mail', 'MailEnabled', 'SecurityEnabled', 'Visibility')
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
            'Property'    = $Property
        }

        if ($Identity) {
            $group = Get-MgGroup -GroupId $Identity @params -ErrorAction SilentlyContinue
            if (-not $group) {
                $group = Get-MgGroup -Filter "displayName eq '$Identity'" @params
            }
        }
        else {
            $params.Add('All', $true)
            $group = Get-MgGroup @params
        }

        if (-not $group) {
            Write-Warning "Group '$Identity' not found."
            return
        }

        $results = foreach ($g in $group) {
            $obj = [ordered]@{}
            foreach ($p in $Property) {
                $obj[$p] = $g.$p
            }
            [PSCustomObject]$obj
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
