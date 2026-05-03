#Requires -Version 5.1
#Requires -Modules NetTCPIP

<#
.SYNOPSIS
    Windows: Retrieves entries from the DNS client cache

.DESCRIPTION
    Lists the DNS records currently stored in the resolver cache on a local or remote computer. Supports filtering by record type and status.

.PARAMETER Type
    Specifies the DNS record type to filter by (e.g., A, AAAA, CNAME, PTR).

.PARAMETER Name
    Specifies a specific name or pattern to search for in the cache. Supports wildcards.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-DnsCacheInfo.ps1 -Type A

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [string]$Type,

    [string]$Name = "*",

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        $dnsParams = @{
            'ErrorAction' = 'Stop'
        }
        if (-not [string]::IsNullOrWhiteSpace($Type)) {
            $dnsParams.Add('Type', $Type)
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $sessionParams = @{
                'ComputerName' = $ComputerName
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $sessionParams.Add('Credential', $Credential)
            }
            $session = New-CimSession @sessionParams
            $dnsParams.Add('CimSession', $session)
        }

        $cacheEntries = Get-DnsClientCache @dnsParams | Where-Object { $_.Name -like $Name }

        $results = foreach ($entry in $cacheEntries) {
            [PSCustomObject]@{
                Name         = $entry.Name
                Type         = $entry.Type
                Status       = $entry.Status
                Data         = $entry.Data
                TimeToLive   = $entry.TimeToLive
                ComputerName = $ComputerName
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
    finally {
        if ($null -ne $session) {
            Remove-CimSession $session
        }
    }
}
