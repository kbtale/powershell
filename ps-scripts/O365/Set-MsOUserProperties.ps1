#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Update Azure AD user properties
.DESCRIPTION
    Modifies properties of an Azure AD user. Only parameters with values are updated.
.PARAMETER UserObjectId
    Unique ID of the user
.PARAMETER UserName
    Display name, Sign-In Name or UPN of the user
.PARAMETER DisplayName
    Display name of the user
.PARAMETER FirstName
    First name of the user
.PARAMETER LastName
    Last name of the user
.PARAMETER PostalCode
    Postal code
.PARAMETER City
    City
.PARAMETER Street
    Street address
.PARAMETER PhoneNumber
    Phone number
.PARAMETER MobilePhone
    Mobile phone number
.PARAMETER Department
    Department
.PARAMETER Title
    Job title
.PARAMETER Country
    Country
.PARAMETER State
    State or province
.PARAMETER UsageLocation
    Usage location (ISO country code)
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Set-MsOUserProperties.ps1 -UserName "user@domain.com" -Department "IT" -Title "Admin"
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
    [string]$DisplayName,
    [string]$FirstName,
    [string]$LastName,
    [string]$PostalCode,
    [string]$City,
    [string]$Street,
    [string]$PhoneNumber,
    [string]$MobilePhone,
    [string]$Department,
    [string]$Title,
    [string]$Country,
    [string]$State,
    [string]$UsageLocation,
    [guid]$TenantId
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $user = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId -ErrorAction Stop }
        else { $user = Get-MsolUser -SearchString $UserName -TenantId $TenantId -ErrorAction Stop | Select-Object -First 1 }

        [hashtable]$setArgs = @{'ErrorAction' = 'Stop'; 'ObjectId' = $user.ObjectId; 'TenantId' = $TenantId}
        $stringParams = @('DisplayName','FirstName','LastName','PostalCode','City','Street','PhoneNumber','MobilePhone','Department','Title','Country','State','UsageLocation')
        foreach ($p in $stringParams) {
            $val = Get-Variable -Name $p -ValueOnly
            if (-not [System.String]::IsNullOrWhiteSpace($val)) { $setArgs.Add($p, $val) }
        }

        Set-MsolUser @setArgs
        $result = Get-MsolUser -ObjectId $user.ObjectId -TenantId $TenantId -ErrorAction Stop | Select-Object *
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
