#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Set user sign-in block status
.DESCRIPTION
    Enables or blocks a user from signing in to Azure Active Directory.
.PARAMETER UserObjectId
    Unique ID of the user
.PARAMETER UserName
    Display name, Sign-In Name or UPN of the user
.PARAMETER Enabled
    User is allowed to sign in (default). Omit to block the user.
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Set-MsOUserBlockStatus.ps1 -UserName "user@domain.com" -Enabled
.EXAMPLE
    PS> ./Set-MsOUserBlockStatus.ps1 -UserName "user@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
    [guid]$UserObjectId,
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
    [string]$UserName,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Id')]
    [switch]$Enabled,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Id')]
    [guid]$TenantId
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $user = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId -ErrorAction Stop }
        else { $user = Get-MsolUser -SearchString $UserName -TenantId $TenantId -ErrorAction Stop | Select-Object -First 1 }

        Set-MsolUser -ObjectId $user.ObjectId -BlockCredential (!$Enabled) -TenantId $TenantId -ErrorAction Stop

        $status = if ($Enabled) { 'enabled' } else { 'blocked' }
        [PSCustomObject]@{ Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; UserName = $user.UserPrincipalName; Status = "User sign-in $status" }
    }
    catch { throw }
}
