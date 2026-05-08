#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Gets mailbox properties for a specified mailbox
.DESCRIPTION
    Retrieves properties of a mailbox from Exchange Online by identity. Supports selecting specific properties or all properties using wildcard.
.PARAMETER MailboxId
    Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox
.PARAMETER Properties
    List of properties to expand. Use * for all properties
.EXAMPLE
    PS> ./Get-MailboxProperties.ps1 -MailboxId "user@domain.com"
.EXAMPLE
    PS> ./Get-MailboxProperties.ps1 -MailboxId "user@domain.com" -Properties '*'
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [ValidateSet('*','DisplayName','FirstName','LastName','Office','Phone','WindowsEmailAddress','AccountDisabled','DistinguishedName','Alias','Guid','ResetPasswordOnNextLogon','UserPrincipalName')]
    [string[]]$Properties = @('DisplayName','FirstName','LastName','Office','Phone','WindowsEmailAddress','AccountDisabled','DistinguishedName','Alias','Guid','ResetPasswordOnNextLogon','UserPrincipalName')
)

Process {
    try {
        $result = Get-Mailbox -Identity $MailboxId -ErrorAction Stop | Select-Object $Properties
        if ($null -eq $result) {
            throw "Mailbox $($MailboxId) not found"
        }
        $result | ForEach-Object {
            $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
