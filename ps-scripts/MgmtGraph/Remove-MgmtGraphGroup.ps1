#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Deletes a Microsoft Graph group

.DESCRIPTION
    Deletes a specifies group from the Microsoft Graph tenant. This action is permanent for security groups but may support restoration for M365 groups within 30 days.

.PARAMETER Identity
    Specifies the ID of the group to delete.

.EXAMPLE
    PS> ./Remove-MgmtGraphGroup.ps1 -Identity "86c75b0a-7b0a-4b0a-8b0a-7b0a8b0a7b0a"

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
            'GroupId'     = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        Remove-MgGroup @params
        
        $result = [PSCustomObject]@{
            GroupId   = $Identity
            Action    = "GroupDeleted"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
