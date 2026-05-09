#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Exports printer drivers to a CSV file.
.DESCRIPTION
    Exports printer drivers from the computer to a CSV file; existing file is overwritten.
.PARAMETER ComputerName
    Name of the computer from which to export the printer drivers.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER ExportFile
    Path and filename of the CSV file to export.
.PARAMETER Delimiter
    Delimiter that separates the property values in the CSV file.
.PARAMETER FileEncoding
    Type of character encoding used in the CSV file.
.EXAMPLE
    PS> ./Export-PrinterDrivers.ps1 -ExportFile 'C:\Temp\drivers.csv'
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ExportFile,
    [string]$Delimiter = ';',
    [ValidateSet('Unicode', 'UTF7', 'UTF8', 'ASCII', 'UTF32', 'BigEndianUnicode', 'Default', 'OEM')]
    [string]$FileEncoding = 'UTF8',
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $drivers = Get-PrinterDriver -CimSession $cim -ComputerName $ComputerName -ErrorAction Stop |
            Select-Object Name, InfPath | Sort-Object Name
        $csv = foreach ($d in $drivers) {
            [PSCustomObject]@{ DriverName = $d.Name; ComputerName = $ComputerName; InfFilePath = $d.InfPath }
        }
        $csv | Export-Csv -Path $ExportFile -Delimiter $Delimiter -Encoding $FileEncoding -Force -NoTypeInformation -ErrorAction Stop
        Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") Printer drivers exported to: $ExportFile"
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
