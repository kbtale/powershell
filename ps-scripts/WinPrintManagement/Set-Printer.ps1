#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Updates printer settings
.DESCRIPTION
    Modifies printer properties including driver, port, and printing defaults.
.PARAMETER PrinterName
    Printer to update
.PARAMETER DriverName
    New driver name
.PARAMETER PortName
    New port name
.PARAMETER ComputerName
    Computer hosting the printer
.PARAMETER AccessAccount
    Optional credential
.EXAMPLE
    PS> ./Set-Printer.ps1 -PrinterName "HP LaserJet" -DriverName "HP Universal Printing PCL 6"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][string]$PrinterName,
    [string]$DriverName,
    [string]$PortName,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop } else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $cmdArgs = @{ ErrorAction = 'Stop'; CimSession = $cim; ComputerName = $ComputerName; Name = $PrinterName; Confirm = $false }
        if (-not [System.String]::IsNullOrWhiteSpace($DriverName)) { $cmdArgs.Add('DriverName', $DriverName) }
        if (-not [System.String]::IsNullOrWhiteSpace($PortName)) { $cmdArgs.Add('PortName', $PortName) }
        $result = Set-Printer @cmdArgs | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
