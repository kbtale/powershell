#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Retrieves mailbox delegation settings
.DESCRIPTION
    Gets the Send As, Send On Behalf, and Full Access delegation settings for a mailbox.
.PARAMETER MailboxId
    Identity of the mailbox (alias, display name, DN, SAM, GUID, or UPN)
.EXAMPLE
    PS> ./Get-MailboxDelegation.ps1 -MailboxId "john.doe@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId
)

Process {
    try {
        $result = [System.Collections.ArrayList]::new()

        $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; DelegationType = "Send As"; Trustee = "---------------" })
        $sendAs = Get-RecipientPermission -Identity $MailboxId -ErrorAction Stop | Select-Object *
        foreach ($item in $sendAs) {
            $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; DelegationType = "Send As"; Trustee = $item.Trustee })
        }

        $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; DelegationType = "Send On Behalf"; Trustee = "---------------" })
        $sendOnBehalf = Get-Mailbox -Identity $MailboxId -ErrorAction Stop | Select-Object -ExpandProperty GrantSendOnBehalfTo
        foreach ($item in $sendOnBehalf) {
            $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; DelegationType = "Send On Behalf"; Trustee = $item })
        }

        $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; DelegationType = "Full Access"; Trustee = "---------------" })
        $fullAccess = Get-MailboxPermission -Identity $MailboxId -ErrorAction Stop | Select-Object *
        foreach ($item in $fullAccess) {
            $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; DelegationType = "Full Access"; Trustee = $item.User })
        }

        Write-Output $result
    }
    catch { throw }
}
