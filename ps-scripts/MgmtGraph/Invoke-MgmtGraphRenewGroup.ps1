#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Renews a Microsoft Graph group

.DESCRIPTION
    Renews an expiring unified group by resetting its expiration date according to the tenant's group lifecycle policies in Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group to renew.

.EXAMPLE
    PS> ./Invoke-MgmtGraphRenewGroup.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId
)

Process {
    try {
        $params = @{
            'GroupId'     = $GroupId
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        Invoke-MgRenewGroup @params

        $result = [PSCustomObject]@{
            GroupId   = $GroupId
            Status    = "Renewed"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
