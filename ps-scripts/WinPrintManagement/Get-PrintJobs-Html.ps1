#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: HTML report of print jobs
.DESCRIPTION
    Generates an HTML report of print jobs.
.PARAMETER ComputerName
    Computer to retrieve print jobs from
.PARAMETER AccessAccount
    Optional credential for remote access
.EXAMPLE
    PS> ./Get-PrintJobs-Html.ps1 -ComputerName "PC01" | Out-File jobs.html
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop } else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $result = Get-PrintJob -CimSession $cim -ComputerName $ComputerName -ErrorAction Stop | Select-Object * | Sort-Object PrinterName
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
