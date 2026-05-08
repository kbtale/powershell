#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Removes emails from a mailbox using compliance search
.DESCRIPTION
    Removes emails from a mailbox in Exchange Online that are older than a specified number of days or before a specified date. Uses compliance search and purge actions.
.PARAMETER O365Account
    Credential with permission to perform compliance actions
.PARAMETER MailboxId
    User principal name of the mailbox
.PARAMETER RemoveOlderDay
    Deletes all emails older than the specified number of days
.PARAMETER RemoveOlderThan
    Deletes all emails up to this date
.PARAMETER PurgeType
    Specifies how to remove items: SoftDelete or HardDelete
.EXAMPLE
    PS> ./Remove-Mails.ps1 -O365Account $cred -MailboxId "user@domain.com" -RemoveOlderDay 30
.EXAMPLE
    PS> ./Remove-Mails.ps1 -O365Account $cred -MailboxId "user@domain.com" -RemoveOlderThan "2024-01-01" -PurgeType HardDelete
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$O365Account,
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [int]$RemoveOlderDay = 90,
    [datetime]$RemoveOlderThan,
    [ValidateSet('SoftDelete', 'HardDelete')]
    [string]$PurgeType = 'SoftDelete'
)

Process {
    try {
        $result = $null
        $compSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $O365Account -Authentication Basic -AllowRedirection
        $null = Import-PSSession $compSession -AllowClobber

        if ($null -eq $RemoveOlderThan) {
            $RemoveOlderThan = (Get-Date).AddDays(-$RemoveOlderDay)
        }

        [string]$searchName = 'SRPurgeSearch'
        try {
            if ($null -ne (Get-ComplianceSearch -Identity $searchName -ErrorAction SilentlyContinue)) {
                $null = Remove-ComplianceSearch -Identity $searchName -Confirm:$false -ErrorAction SilentlyContinue
            }
            $null = New-ComplianceSearch -Name $searchName -ExchangeLocation $MailboxId -ContentMatchQuery "Received<$($RemoveOlderThan.ToString('yyyy-MM-dd'))(c:c)(ItemClass=IPM.Note)" -ErrorAction Stop
            $job = Start-ComplianceSearch -Identity $searchName -AsJob
            try {
                while ($job.State -eq 'Running') {
                    Start-Sleep -Seconds 1
                }
                if ($job.State -eq 'Completed') {
                    Start-Sleep -Seconds 5
                    $res = (Get-ComplianceSearch -Identity $searchName -ErrorAction Stop | Select-Object -ExpandProperty Items)
                    if ($res -gt 0) {
                        $sAct = New-ComplianceSearchAction -SearchName $searchName -Purge -PurgeType $PurgeType -Force -Confirm:$false -ErrorAction Stop | Select-Object -ExpandProperty Status
                        try {
                            while (($sAct -eq 'Starting') -or ($sAct -eq 'InProgress')) {
                                Start-Sleep -Seconds 1
                                $sAct = (Get-ComplianceSearchAction -Identity "$($searchName)_Purge" -ErrorAction Stop | Select-Object -ExpandProperty Status)
                            }
                            if ($sAct -eq 'Completed') {
                                $result = Get-ComplianceSearchAction -Identity "$($searchName)_Purge" -ErrorAction Stop | Select-Object -ExpandProperty Results
                            }
                            else {
                                throw "Search action failed"
                            }
                        }
                        finally {
                            $null = Remove-ComplianceSearchAction -Identity "$($searchName)_Purge" -Confirm:$false -ErrorAction SilentlyContinue
                        }
                    }
                    else {
                        $result = 'No mails to delete found'
                    }
                }
                else {
                    throw "Search mails failed"
                }
            }
            finally {
                $null = Remove-ComplianceSearch -Identity $searchName -Confirm:$false -ErrorAction SilentlyContinue
            }
        }
        finally {
            $null = Remove-PSSession -Session $compSession -Confirm:$false
        }

        [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Result    = $result
        }
    }
    catch { throw }
}
