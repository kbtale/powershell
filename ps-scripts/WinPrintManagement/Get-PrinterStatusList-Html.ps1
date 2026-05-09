#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: HTML report of printer status list
.DESCRIPTION
    Generates an HTML report of printer status events.
.PARAMETER ComputerName
    Computer to retrieve printer status from
.EXAMPLE
    PS> ./Get-PrinterStatusList-Html.ps1 -ComputerName "PC01" | Out-File status.html
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param([string]$ComputerName)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $result = Get-WinEvent -LogName "Microsoft-Windows-PrintService/Admin" -ComputerName $ComputerName -MaxEvents 50 -ErrorAction Stop | Select-Object TimeCreated, Id, LevelDisplayName, Message
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
