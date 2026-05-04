#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits settings for a Microsoft Graph user

.DESCRIPTION
    Retrieves personal settings for a specifies Microsoft Graph user, such as regional preferences, shift preferences, or external application settings.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphUserSetting.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $settings = Get-MgUserSetting -UserId $Identity -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            UserIdentity = $Identity
            Id           = $settings.Id
            ContributionToContentDiscoveryAsOrganizationDisabled = $settings.ContributionToContentDiscoveryAsOrganizationDisabled
            ContributionToContentDiscoveryDisabled = $settings.ContributionToContentDiscoveryDisabled
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
