#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Creates a new Resource Mailbox

.DESCRIPTION
    Creates a new Microsoft Exchange resource mailbox (Room or Equipment) with specified administrative properties and capacity.

.PARAMETER Name
    Specifies the unique name of the resource.

.PARAMETER Type
    Specifies the type of resource (Room or Equipment). Defaults to Room.

.PARAMETER Alias
    Optional. Specifies the Exchange alias.

.PARAMETER DisplayName
    Optional. Specifies the display name.

.PARAMETER Capacity
    Optional. Specifies the capacity of the resource (e.g., number of seats).

.PARAMETER PrimarySmtpAddress
    Optional. Specifies the primary SMTP address.

.PARAMETER AccountDisabled
    If set, disables the associated Active Directory user account. Defaults to true for resource mailboxes.

.EXAMPLE
    PS> ./New-ExchangeResource.ps1 -Name "Conference Room A" -Type Room -Capacity 12

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [ValidateSet('Room', 'Equipment')]
    [string]$Type = 'Room',

    [string]$Alias,

    [string]$DisplayName,

    [int]$Capacity,

    [string]$PrimarySmtpAddress,

    [bool]$AccountDisabled = $true
)

Process {
    try {
        $params = @{
            'Name'            = $Name
            'Confirm'         = $false
            'ErrorAction'     = 'Stop'
            'AccountDisabled' = $AccountDisabled
        }
        if ($Type -eq 'Room') { $params.Add('Room', $true) } else { $params.Add('Equipment', $true) }
        if ($Alias) { $params.Add('Alias', $Alias) }
        if ($DisplayName) { $params.Add('DisplayName', $DisplayName) }
        if ($PrimarySmtpAddress) { $params.Add('PrimarySmtpAddress', $PrimarySmtpAddress) }
        if ($PSBoundParameters.ContainsKey('Capacity')) { $params.Add('ResourceCapacity', $Capacity) }

        $resource = New-Mailbox @params

        $result = [PSCustomObject]@{
            Name               = $resource.Name
            DisplayName        = $resource.DisplayName
            ResourceType       = $resource.RecipientTypeDetails
            PrimarySmtpAddress = $resource.PrimarySmtpAddress
            Action             = "ResourceCreated"
            Status             = "Success"
            Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
