#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement.Functions

<#
.SYNOPSIS
    MgmtGraph: Verifies Windows enrollment autodiscovery

.DESCRIPTION
    Validates if a specifies domain is correctly configured for Windows device enrollment autodiscovery in Microsoft Graph.

.PARAMETER DomainName
    Specifies the domain name to verify.

.EXAMPLE
    PS> ./Confirm-MgmtGraphWindowEnrollmentAutoDiscovery.ps1 -DomainName "contoso.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$DomainName
)

Process {
    try {
        $confirmation = Confirm-MgDeviceManagementWindowEnrollmentAutoDiscovery -DomainName $DomainName -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            DomainName  = $DomainName
            IsConfirmed = $confirmation.Value
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
