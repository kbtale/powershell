#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Removes a printer
.DESCRIPTION
    Removes a printer from the specified computer.
.PARAMETER PrinterName
    Name of the printer to remove
.PARAMETER ComputerName
    Computer hosting the printer
.PARAMETER AccessAccount
    Optional credential for remote access
.EXAMPLE
    PS> ./Remove-Printer.ps1 -PrinterName "HP LaserJet" -ComputerName "PC01"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][string]$PrinterName,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop } else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        Remove-Printer -CimSession $cim -ComputerName $ComputerName -Name $PrinterName -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; PrinterName = $PrinterName; ComputerName = $ComputerName; Message = "Printer '$PrinterName' removed" }
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
