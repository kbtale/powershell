#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Sets mailbox properties
.DESCRIPTION
    Sets properties of a mailbox in Exchange Online. Only parameters with values are applied.
.PARAMETER MailboxId
    Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox
.PARAMETER UserPrincipalName
    New user principal name for the mailbox
.PARAMETER Alias
    Alias name of the mailbox
.PARAMETER DisplayName
    Display name of the mailbox
.PARAMETER WindowsEmailAddress
    Windows email address of the mailbox
.PARAMETER FirstName
    User's first name
.PARAMETER LastName
    User's last name
.PARAMETER Office
    User's physical office name or number
.PARAMETER Phone
    User's telephone number
.PARAMETER ResetPasswordOnNextLogon
    User is required to change their password the next time they log on
.PARAMETER AccountDisabled
    Disable the account associated with the mailbox
.EXAMPLE
    PS> ./Set-MailboxProperties.ps1 -MailboxId "user@domain.com" -DisplayName "John Doe" -Office "Building A"
.EXAMPLE
    PS> ./Set-MailboxProperties.ps1 -MailboxId "user@domain.com" -AccountDisabled
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [string]$UserPrincipalName,
    [string]$Alias,
    [string]$DisplayName,
    [string]$WindowsEmailAddress,
    [string]$FirstName,
    [string]$LastName,
    [string]$Office,
    [string]$Phone,
    [switch]$ResetPasswordOnNextLogon,
    [switch]$AccountDisabled
)

Process {
    try {
        [string[]]$Properties = @('AccountDisabled','Alias','DisplayName','Name','FirstName','LastName','Office','Phone','WindowsEmailAddress','ResetPasswordOnNextLogon','UserPrincipalName')

        $box = Get-Mailbox -Identity $MailboxId -ErrorAction Stop
        if ($null -eq $box) {
            throw "Mailbox $($MailboxId) not found"
        }

        if ($PSBoundParameters.ContainsKey('AccountDisabled')) {
            $null = Set-Mailbox -Identity $box.UserPrincipalName -AccountDisabled $true -Confirm:$false -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('Alias')) {
            $null = Set-Mailbox -Identity $box.UserPrincipalName -Alias $Alias -Confirm:$false -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('DisplayName')) {
            $null = Set-Mailbox -Identity $box.UserPrincipalName -DisplayName $DisplayName -Confirm:$false -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('FirstName')) {
            $null = Set-User -Identity $box.UserPrincipalName -FirstName $FirstName -Confirm:$false -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('LastName')) {
            $null = Set-User -Identity $box.UserPrincipalName -LastName $LastName -Confirm:$false -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('Office')) {
            $null = Set-User -Identity $box.UserPrincipalName -Office $Office -Confirm:$false -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('Phone')) {
            $null = Set-User -Identity $box.UserPrincipalName -Phone $Phone -Confirm:$false -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('WindowsEmailAddress')) {
            $null = Set-Mailbox -Identity $box.UserPrincipalName -WindowsEmailAddress $WindowsEmailAddress -Confirm:$false -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('ResetPasswordOnNextLogon')) {
            $null = Set-User -Identity $box.UserPrincipalName -ResetPasswordOnNextLogon $true -Confirm:$false -ErrorAction Stop
        }

        $result = Get-Mailbox -Identity $box.Name -ErrorAction Stop | Select-Object $Properties
        $result | ForEach-Object {
            $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
