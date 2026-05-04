#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Retrieves DNS verification records for a Microsoft Graph domain

.DESCRIPTION
    Retrieves the TXT or MX records that must be published in the domain's DNS zone to prove ownership and complete verification in Microsoft Graph.

.PARAMETER Identity
    Specifies the name of the domain to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphDomainVerificationRecord.ps1 -Identity "contoso.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $records = Get-MgDomainVerificationDnsRecord -DomainId $Identity -ErrorAction Stop
        
        $results = foreach ($r in $records) {
            [PSCustomObject]@{
                DomainName  = $Identity
                RecordType  = $r.RecordType
                Label       = $r.Label
                Text        = $r.Text
                Ttl         = $r.Ttl
                IsVerified  = $r.IsVerified
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
