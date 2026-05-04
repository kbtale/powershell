#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Generates a detailed audit report of Mailbox Databases

.DESCRIPTION
    Retrieves a comprehensive set of properties for all Mailbox Databases, including storage quotas and health status indicators.

.EXAMPLE
    PS> ./Get-ExchangeDatabaseReport.ps1

.CATEGORY Exchange
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $databases = Get-MailboxDatabase -Status -ErrorAction Stop

        $results = foreach ($db in $databases) {
            [PSCustomObject]@{
                Name                        = $db.Name
                Server                      = $db.Server.Name
                DatabaseSize                = if ($db.DatabaseSize) { $db.DatabaseSize.ToGB() } else { "N/A" }
                AvailableNewMailboxSpace    = if ($db.AvailableNewMailboxSpace) { $db.AvailableNewMailboxSpace.ToGB() } else { "N/A" }
                ProhibitSendReceiveQuota    = $db.ProhibitSendReceiveQuota
                ProhibitSendQuota           = $db.ProhibitSendQuota
                IssueWarningQuota           = $db.IssueWarningQuota
                IndexEnabled                = $db.IndexEnabled
                Mounted                     = $db.Mounted
                DistinguishedName           = $db.DistinguishedName
                LastModified                = $db.WhenChanged
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
