#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Modifies user properties
.DESCRIPTION
    Updates properties of an Azure AD user. Only supplied parameters are applied.
.PARAMETER UserObjectId
    Unique object ID of the user to modify
.PARAMETER UserName
    Display name or UPN of the user to modify
.PARAMETER DisplayName
    New display name for the user
.PARAMETER FirstName
    First name of the user
.PARAMETER LastName
    Last name of the user
.PARAMETER PostalCode
    Postal code of the user
.PARAMETER City
    City of the user
.PARAMETER Street
    Street address of the user
.PARAMETER PhoneNumber
    Phone number of the user
.PARAMETER MobilePhone
    Mobile phone number of the user
.PARAMETER Department
    Department of the user
.PARAMETER Enabled
    Whether the account is enabled for sign-in
.EXAMPLE
    PS> ./Set-UserProperty.ps1 -UserName "john.doe@contoso.com" -Department "Sales"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "UserName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "UserObjectId")]
    [guid]$UserObjectId,

    [Parameter(Mandatory = $true, ParameterSetName = "UserName")]
    [string]$UserName,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [string]$DisplayName,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [string]$FirstName,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [string]$LastName,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [string]$PostalCode,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [string]$City,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [string]$Street,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [string]$PhoneNumber,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [string]$MobilePhone,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [string]$Department,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [bool]$Enabled
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq "UserObjectId") {
            $usr = Get-AzureADUser -ObjectId $UserObjectId -ErrorAction Stop | Select-Object ObjectID, DisplayName
        }
        else {
            $usr = Get-AzureADUser -All $true -ErrorAction Stop | Where-Object { ($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName) } | Select-Object ObjectID, DisplayName
        }

        if ($null -eq $usr) { throw "User not found" }

        if ($PSBoundParameters.ContainsKey('DisplayName')) { $null = Set-AzureADUser -ObjectId $usr.ObjectId -DisplayName $DisplayName -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('FirstName')) { $null = Set-AzureADUser -ObjectId $usr.ObjectId -GivenName $FirstName -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('LastName')) { $null = Set-AzureADUser -ObjectId $usr.ObjectId -Surname $LastName -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('PostalCode')) { $null = Set-AzureADUser -ObjectId $usr.ObjectId -PostalCode $PostalCode -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('City')) { $null = Set-AzureADUser -ObjectId $usr.ObjectId -City $City -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('Street')) { $null = Set-AzureADUser -ObjectId $usr.ObjectId -StreetAddress $Street -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('PhoneNumber')) { $null = Set-AzureADUser -ObjectId $usr.ObjectId -TelephoneNumber $PhoneNumber -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('MobilePhone')) { $null = Set-AzureADUser -ObjectId $usr.ObjectId -Mobile $MobilePhone -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('Department')) { $null = Set-AzureADUser -ObjectId $usr.ObjectId -Department $Department -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('Enabled')) { $null = Set-AzureADUser -ObjectId $usr.ObjectId -AccountEnabled $Enabled -ErrorAction Stop }

        $updated = Get-AzureADUser -ObjectId $usr.ObjectId -ErrorAction Stop | Select-Object *
        $updated | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
    }
    catch { throw }
}
