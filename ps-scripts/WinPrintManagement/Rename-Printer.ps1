#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Renames a printer
.DESCRIPTION
    Renames a printer on the specified computer.
.PARAMETER PrinterName
    Current name of the printer
.PARAMETER NewName
    New name for the printer
.PARAMETER ComputerName
    Computer hosting the printer
.PARAMETER AccessAccount
    Optional credential
.EXAMPLE
    PS> ./Rename-Printer.ps1 -PrinterName "HP LaserJet" -NewName "Floor3-HP"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][string]$PrinterName,
    [Parameter(Mandatory = $true)][string]$NewName,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop } else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        Rename-Printer -CimSession $cim -ComputerName $ComputerName -Name $PrinterName -NewName $NewName -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; OldName = $PrinterName; NewName = $NewName; ComputerName = $ComputerName; Message = "Printer renamed to '$NewName'" }
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
