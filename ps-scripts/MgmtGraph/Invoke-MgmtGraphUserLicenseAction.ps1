#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Manages license assignments for a Microsoft Graph user

.DESCRIPTION
    Adds or removes licenses for a specifies Microsoft Graph user account by SKU ID.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to manage.

.PARAMETER AddLicense
    Optional. Specifies an array of SKU IDs to assign to the user.

.PARAMETER RemoveLicense
    Optional. Specifies an array of SKU IDs to remove from the user.

.EXAMPLE
    PS> ./Invoke-MgmtGraphUserLicenseAction.ps1 -Identity "user@example.com" -AddLicense "c7df523c-6837-42f5-bb10-af100c5c4e3f"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string[]]$AddLicense,

    [string[]]$RemoveLicense
)

Process {
    try {
        $addList = @()
        foreach ($sku in $AddLicense) {
            $addList += @{ SkuId = $sku }
        }

        $params = @{
            'UserId'         = $Identity
            'AddLicenses'    = $addList
            'RemoveLicenses' = $RemoveLicense
            'ErrorAction'    = 'Stop'
        }

        $user = Set-MgUserLicense @params
        
        $result = [PSCustomObject]@{
            Identity      = $Identity
            AddedCount    = ($AddLicense | Measure-Object).Count
            RemovedCount  = ($RemoveLicense | Measure-Object).Count
            Action        = "LicenseActionExecuted"
            Status        = "Success"
            Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
