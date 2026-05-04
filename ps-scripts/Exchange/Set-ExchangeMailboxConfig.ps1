#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Modifies properties of a mailbox and its associated user

.DESCRIPTION
    Updates various attributes of a Microsoft Exchange mailbox and the linked Active Directory user account. Supports modifying names, contact information, and aliases.

.PARAMETER Identity
    Specifies the Identity of the mailbox.

.PARAMETER Alias
    Optional. Specifies a new Exchange alias.

.PARAMETER DisplayName
    Optional. Specifies a new display name.

.PARAMETER PrimarySmtpAddress
    Optional. Specifies a new primary SMTP address.

.PARAMETER FirstName
    Optional. Specifies the user's first name.

.PARAMETER LastName
    Optional. Specifies the user's last name.

.PARAMETER Office
    Optional. Specifies the user's office location.

.PARAMETER Phone
    Optional. Specifies the user's phone number.

.PARAMETER ResetPasswordOnNextLogon
    Optional. If set, forces the user to change their password at the next logon.

.EXAMPLE
    PS> ./Set-ExchangeMailboxConfig.ps1 -Identity "user1" -DisplayName "User One" -Office "HQ"

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [string]$Alias,
    [string]$DisplayName,
    [string]$PrimarySmtpAddress,
    [string]$FirstName,
    [string]$LastName,
    [string]$Office,
    [string]$Phone,
    [bool]$ResetPasswordOnNextLogon
)

Process {
    try {
        $mailboxParams = @{
            'Identity'    = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }
        if ($PSBoundParameters.ContainsKey('Alias')) { $mailboxParams.Add('Alias', $Alias) }
        if ($PSBoundParameters.ContainsKey('DisplayName')) { $mailboxParams.Add('DisplayName', $DisplayName) }
        if ($PSBoundParameters.ContainsKey('PrimarySmtpAddress')) { $mailboxParams.Add('PrimarySmtpAddress', $PrimarySmtpAddress) }

        if ($mailboxParams.Count -gt 3) {
            Set-Mailbox @mailboxParams
        }

        $userParams = @{
            'Identity'    = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }
        if ($PSBoundParameters.ContainsKey('FirstName')) { $userParams.Add('FirstName', $FirstName) }
        if ($PSBoundParameters.ContainsKey('LastName')) { $userParams.Add('LastName', $LastName) }
        if ($PSBoundParameters.ContainsKey('Office')) { $userParams.Add('Office', $Office) }
        if ($PSBoundParameters.ContainsKey('Phone')) { $userParams.Add('Phone', $Phone) }
        if ($PSBoundParameters.ContainsKey('ResetPasswordOnNextLogon')) { $userParams.Add('ResetPasswordOnNextLogon', $ResetPasswordOnNextLogon) }

        if ($userParams.Count -gt 3) {
            Set-User @userParams
        }

        $mailbox = Get-Mailbox -Identity $Identity -ErrorAction Stop
        $user = Get-User -Identity $Identity -ErrorAction Stop

        $result = [PSCustomObject]@{
            Identity    = $Identity
            DisplayName = $mailbox.DisplayName
            Alias       = $mailbox.Alias
            Office      = $user.Office
            Phone       = $user.Phone
            Action      = "MailboxConfigUpdated"
            Status      = "Success"
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
