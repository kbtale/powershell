#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits registered devices for a Microsoft Graph user

.DESCRIPTION
    Retrieves the list of devices registered to a specifies Microsoft Graph user, including OS details, trust type, and registration timestamps.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphUserRegisteredDevice.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $devices = Get-MgUserRegisteredDevice -UserId $Identity -All -ErrorAction Stop
        
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
