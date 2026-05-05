#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Audits registered owners for a Microsoft Graph device

.DESCRIPTION
    Retrieves the list of users or service principals that are registered owners of a specifies device.

.PARAMETER Identity
    Specifies the ID of the device to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceRegisteredOwner.ps1 -Identity "device-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $owners = Get-MgDeviceRegisteredOwner -DeviceId $Identity -All -ErrorAction Stop
        
        $results = foreach ($o in $owners) {
            [PSCustomObject]@{
                DisplayName       = $o.AdditionalProperties.displayName
                UserPrincipalName = $o.AdditionalProperties.userPrincipalName
                Type              = $o.AdditionalProperties.'@odata.type'.Replace('#microsoft.graph.', '')
                Id                = $o.Id
                Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
