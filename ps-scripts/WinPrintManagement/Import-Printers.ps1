#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Imports printers from a file
.DESCRIPTION
    Imports printer configurations from a backup file to the specified computer.
.PARAMETER ComputerName
    Target computer for printer import
.PARAMETER FilePath
    Path to the printer export file
.PARAMETER AccessAccount
    Optional credential for remote access
.EXAMPLE
    PS> ./Import-Printers.ps1 -ComputerName "PC01" -FilePath "C:\backup\printers.xml"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop } else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        if (-not (Test-Path $FilePath)) { throw "File '$FilePath' not found" }
        $result = Import-Printer -File $FilePath -CimSession $cim -ComputerName $ComputerName -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; File = $FilePath; ComputerName = $ComputerName; Message = "Printers imported successfully" }
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
