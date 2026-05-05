#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Audits registered users for a Microsoft Graph device

.DESCRIPTION
    Retrieves the list of users that are registered as users of a specifies device.

.PARAMETER Identity
    Specifies the ID of the device to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceRegisteredUser.ps1 -Identity "device-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $users = Get-MgDeviceRegisteredUser -DeviceId $Identity -All -ErrorAction Stop
        
        $results = foreach ($u in $users) {
            [PSCustomObject]@{
                DisplayName       = $u.AdditionalProperties.displayName
                UserPrincipalName = $u.AdditionalProperties.userPrincipalName
                Type              = $u.AdditionalProperties.'@odata.type'.Replace('#microsoft.graph.', '')
                Id                = $u.Id
                Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
