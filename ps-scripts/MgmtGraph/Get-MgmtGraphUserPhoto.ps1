#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits profile photo metadata for a Microsoft Graph user

.DESCRIPTION
    Retrieves metadata for a specifies Microsoft Graph user's profile photo, such as dimensions, media type, and ID.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphUserPhoto.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $photo = Get-MgUserPhoto -UserId $Identity -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            UserIdentity = $Identity
            Id           = $photo.Id
            Height       = $photo.Height
            Width        = $photo.Width
            ODataType    = $photo.AdditionalProperties.'@odata.type'
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
