#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: HTML report of printer errors
.DESCRIPTION
    Generates an HTML report of printer error events.
.PARAMETER ComputerName
    Computer to retrieve printer errors from
.EXAMPLE
    PS> ./Get-PrinterErrorsList-Html.ps1 -ComputerName "PC01" | Out-File errors.html
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param([string]$ComputerName)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $result = Get-WinEvent -LogName "Microsoft-Windows-PrintService/Operational" -ComputerName $ComputerName -MaxEvents 100 -ErrorAction Stop | Where-Object { $_.Level -ge 2 } | Select-Object TimeCreated, Id, LevelDisplayName, Message
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
