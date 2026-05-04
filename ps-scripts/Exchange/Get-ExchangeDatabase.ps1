#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Lists all Mailbox Databases

.DESCRIPTION
    Retrieves an inventory of all Mailbox Databases configured in the Exchange organization, including their status and server location.

.PARAMETER Identity
    Optional. Specifies the Identity of a specific database to retrieve.

.PARAMETER IncludeStatus
    If set, retrieves detailed health and replication status (On-Premises only).

.EXAMPLE
    PS> ./Get-ExchangeDatabase.ps1

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [string]$Identity,

    [switch]$IncludeStatus
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }
        if ($Identity) { $params.Add('Identity', $Identity) }
        if ($IncludeStatus.IsPresent) { $params.Add('Status', $true) }

        $databases = Get-MailboxDatabase @params

        $results = foreach ($db in $databases) {
            [PSCustomObject]@{
                Name           = $db.Name
                Server         = $db.Server.Name
                Recovery       = $db.Recovery
                CircularLoggingEnabled = $db.CircularLoggingEnabled
                DatabaseSize   = if ($db.DatabaseSize) { $db.DatabaseSize.ToGB() } else { "N/A" }
                Mounted        = $db.Mounted
                LastModified   = $db.WhenChanged
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
