#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Restore a deleted Azure AD user
.DESCRIPTION
    Restores a deleted user from the Azure AD recycle bin.
.PARAMETER UserObjectId
    Unique ID of the user to restore
.PARAMETER UserName
    Display name, Sign-In Name or UPN of the user to restore
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Restore-MsOUser.ps1 -UserName "user@domain.com"
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
    [guid]$TenantId
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $user = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId -ReturnDeletedUsers -ErrorAction Stop }
        else { $user = Get-MsolUser -SearchString $UserName -TenantId $TenantId -ReturnDeletedUsers -ErrorAction Stop | Select-Object -First 1 }

        $null = Restore-MsolUser -ObjectId $user.ObjectId -TenantId $TenantId -ErrorAction Stop

        [PSCustomObject]@{ Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; UserName = $user.UserPrincipalName; Status = "User '$($user.UserPrincipalName)' restored" }
    }
    catch { throw }
}
