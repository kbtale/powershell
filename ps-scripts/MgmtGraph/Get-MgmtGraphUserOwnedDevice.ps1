#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits owned devices for a Microsoft Graph user

.DESCRIPTION
    Retrieves the list of devices owned by a specifies Microsoft Graph user, typically including corporate-owned or personally-owned devices registered in the tenant.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphUserOwnedDevice.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $devices = Get-MgUserOwnedDevice -UserId $Identity -All -ErrorAction Stop
        
        $results = foreach ($d in $devices) {
            [PSCustomObject]@{
                DisplayName     = $d.AdditionalProperties.displayName
                DeviceId        = $d.AdditionalProperties.deviceId
                OS              = $d.AdditionalProperties.operatingSystem
                OSVersion       = $d.AdditionalProperties.operatingSystemVersion
                TrustType       = $d.AdditionalProperties.trustType
                AccountEnabled  = $d.AdditionalProperties.accountEnabled
                CreatedDateTime = $d.AdditionalProperties.createdDateTime
                Id              = $d.Id
                Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
