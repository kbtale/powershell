#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Updates Microsoft Graph device properties

.DESCRIPTION
    Modifies configuration details for a specifies device, such as its display name, OS details, and compliance status.

.PARAMETER Identity
    Specifies the ID of the device to update.

.PARAMETER DisplayName
    Optional. Specifies the new display name for the device.

.PARAMETER AccountEnabled
    Optional. Specifies whether the device account is enabled.

.PARAMETER IsCompliant
    Optional. Specifies whether the device complies with MDM policies.

.PARAMETER OS
    Optional. Specifies the operating system name.

.PARAMETER OSVersion
    Optional. Specifies the operating system version.

.EXAMPLE
    PS> ./Set-MgmtGraphDevice.ps1 -Identity "device-id" -DisplayName "Work Laptop"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string]$DisplayName,

    [bool]$AccountEnabled,

    [bool]$IsCompliant,

    [string]$OS,

    [string]$OSVersion
)

Process {
    try {
        $params = @{
            'DeviceId'    = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('DisplayName')) { $params.Add('DisplayName', $DisplayName) }
        if ($PSBoundParameters.ContainsKey('AccountEnabled')) { $params.Add('AccountEnabled', $AccountEnabled) }
        if ($PSBoundParameters.ContainsKey('IsCompliant')) { $params.Add('IsCompliant', $IsCompliant) }
        if ($PSBoundParameters.ContainsKey('OS')) { $params.Add('OperatingSystem', $OS) }
        if ($PSBoundParameters.ContainsKey('OSVersion')) { $params.Add('OperatingSystemVersion', $OSVersion) }

        if ($params.Count -gt 3) {
            Update-MgDevice @params
            
            $result = [PSCustomObject]@{
                DeviceId  = $Identity
                Action    = "DeviceUpdated"
                Status    = "Success"
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
        else {
            Write-Warning "No properties specified to update for device."
        }
    }
    catch {
        throw
    }
}
