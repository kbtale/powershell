#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Creates a new Distribution Group

.DESCRIPTION
    Creates a new Microsoft Exchange Distribution Group or mail-enabled security group with specified properties and initial members.

.PARAMETER Name
    Specifies the unique name of the group.

.PARAMETER ManagedBy
    Specifies the owner/manager of the group.

.PARAMETER Alias
    Specifies the Exchange alias for the group.

.PARAMETER DisplayName
    Specifies the display name for the group.

.PARAMETER PrimarySmtpAddress
    Specifies the primary email address for the group.

.PARAMETER Type
    Specifies the type of group (Distribution or Security). Defaults to Distribution.

.PARAMETER Members
    Specifies an optional array of members to add to the group upon creation.

.EXAMPLE
    PS> ./New-ExchangeDistributionGroup.ps1 -Name "Project X" -ManagedBy "admin@contoso.com"

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$ManagedBy,

    [string]$Alias,

    [string]$DisplayName,

    [string]$PrimarySmtpAddress,

    [ValidateSet('Distribution', 'Security')]
    [string]$Type = 'Distribution',

    [string[]]$Members
)

Process {
    try {
        $params = @{
            'Name'               = $Name
            'ManagedBy'          = $ManagedBy
            'Type'               = $Type
            'Confirm'            = $false
            'ErrorAction'        = 'Stop'
        }
        if ($Alias) { $params.Add('Alias', $Alias) }
        if ($DisplayName) { $params.Add('DisplayName', $DisplayName) }
        if ($PrimarySmtpAddress) { $params.Add('PrimarySmtpAddress', $PrimarySmtpAddress) }
        if ($Members) { $params.Add('Members', $Members) }

        $group = New-DistributionGroup @params

        $result = [PSCustomObject]@{
            Name           = $group.Name
            DisplayName    = $group.DisplayName
            PrimarySmtpAddress = $group.PrimarySmtpAddress
            Action         = "DistributionGroupCreated"
            Status         = "Success"
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
