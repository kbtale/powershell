#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Retrieves all properties of a user
.DESCRIPTION
    Gets every property of a specified Azure AD user identified by object ID or display name/UPN.
.PARAMETER UserObjectId
    Unique object ID of the user
.PARAMETER UserName
    Display name or user principal name of the user
.EXAMPLE
    PS> ./Get-UserProperty.ps1 -UserName "john.doe@contoso.com"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "UserName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "UserObjectId")]
    [guid]$UserObjectId,

    [Parameter(Mandatory = $true, ParameterSetName = "UserName")]
    [string]$UserName
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq "UserObjectId") {
            $usr = Get-AzureADUser -ObjectId $UserObjectId -ErrorAction Stop | Select-Object *
        }
        else {
            $usr = Get-AzureADUser -All $true -ErrorAction Stop | Where-Object { ($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName) } | Select-Object *
        }

        if ($null -eq $usr) { throw "User not found" }

        $usr | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
    }
    catch { throw }
}
