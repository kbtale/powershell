#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Removes mailbox delegations
.DESCRIPTION
    Removes SendAs, SendOnBehalf, and FullAccess delegations from a mailbox in Exchange Online.
.PARAMETER MailboxId
    Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox
.PARAMETER SendAsTrustees
    Users or groups from which to remove SendAs permission (Name, Guid or UPN)
.PARAMETER SendOnBehalfTrustees
    Users or groups from which to remove SendOnBehalf permission (Name, Guid or UPN)
.PARAMETER FullAccessTrustees
    Users or groups from which to remove FullAccess permission (Name, Guid or UPN)
.EXAMPLE
    PS> ./Remove-MailboxDelegation.ps1 -MailboxId "user@domain.com" -SendAsTrustees "delegate@domain.com"
.EXAMPLE
    PS> ./Remove-MailboxDelegation.ps1 -MailboxId "user@domain.com" -FullAccessTrustees @("user1@domain.com","user2@domain.com")
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [string[]]$SendAsTrustees,
    [string[]]$SendOnBehalfTrustees,
    [string[]]$FullAccessTrustees
)

Process {
    try {
        $output = New-Object System.Collections.Generic.Queue[string]
        [hashtable]$cmdArgs = @{ErrorAction = 'Stop'; Identity = $MailboxId; Confirm = $false}

        if ($PSBoundParameters.ContainsKey('SendAsTrustees')) {
            foreach ($item in $SendAsTrustees) {
                $null = Remove-RecipientPermission @cmdArgs -AccessRights SendAs -Trustee $item
            }
            $output.Enqueue('Send As')
            $output.Enqueue('---------------')
            $tmp = Get-RecipientPermission -Identity $MailboxId -ErrorAction Stop | Select-Object *
            foreach ($item in $tmp) {
                $output.Enqueue($item.Trustee)
            }
            $output.Enqueue(' ')
        }

        if ($PSBoundParameters.ContainsKey('SendOnBehalfTrustees')) {
            $null = Set-Mailbox @cmdArgs -GrantSendOnBehalfTo @{Remove = $SendOnBehalfTrustees} -Force
            $output.Enqueue('Send On Behalf')
            $output.Enqueue('---------------')
            $tmp = Get-Mailbox -Identity $MailboxId -ErrorAction Stop | Select-Object -ExpandProperty GrantSendOnBehalfTo
            foreach ($item in $tmp) {
                $output.Enqueue($item)
            }
            $output.Enqueue(' ')
        }

        if ($PSBoundParameters.ContainsKey('FullAccessTrustees')) {
            foreach ($item in $FullAccessTrustees) {
                $null = Remove-MailboxPermission @cmdArgs -User $item -AccessRights FullAccess -InheritanceType All
            }
            $output.Enqueue('Full Access')
            $output.Enqueue('---------------')
            $tmp = Get-MailboxPermission -Identity $MailboxId -ErrorAction Stop | Select-Object *
            foreach ($item in $tmp) {
                $output.Enqueue($item.User)
            }
        }

        [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Result    = $output.ToArray()
        }
    }
    catch { throw }
}
