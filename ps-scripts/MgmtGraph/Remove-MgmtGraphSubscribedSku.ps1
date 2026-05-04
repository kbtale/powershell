#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Deletes a tenant license subscription (SKU)

.DESCRIPTION
    Removes a specifies license subscription from the Microsoft Graph tenant. This action is irreversible.

.PARAMETER Identity
    Specifies the ID of the Subscribed SKU to remove.

.EXAMPLE
    PS> ./Remove-MgmtGraphSubscribedSku.ps1 -Identity "sku-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $params = @{
            'SubscribedSkuId' = $Identity
            'Confirm'         = $false
            'ErrorAction'     = 'Stop'
        }

        Remove-MgSubscribedSku @params
        
        $result = [PSCustomObject]@{
            SkuId     = $Identity
            Action    = "SubscribedSkuRemoved"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
