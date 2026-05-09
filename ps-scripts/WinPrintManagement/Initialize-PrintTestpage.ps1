#Requires -Version 5.1

<#
.SYNOPSIS
    Print Management: Prints a test page
.DESCRIPTION
    Sends a test page to the specified printer.
.PARAMETER PrinterName
    Name of the printer to test
.PARAMETER ComputerName
    Computer hosting the printer
.EXAMPLE
    PS> ./Initialize-PrintTestpage.ps1 -PrinterName "HP LaserJet"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [string]$ComputerName
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        if ($ComputerName -eq [System.Net.DNS]::GetHostByName('').HostName) {
            $printer = Get-WmiObject -Class Win32_Printer -Filter "Name='$PrinterName'" -ErrorAction Stop
        }
        else {
            $printer = Get-WmiObject -Class Win32_Printer -ComputerName $ComputerName -Filter "Name='$PrinterName'" -ErrorAction Stop
        }
        if ($null -eq $printer) { throw "Printer '$PrinterName' not found" }
        $result = $printer.PrintTestPage()
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; PrinterName = $PrinterName; ComputerName = $ComputerName; ReturnValue = $result.ReturnValue }
    }
    catch { throw }
}
