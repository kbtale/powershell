#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Exports local printers from a computer to a CSV file.
.DESCRIPTION
    Exports local printers from the computer to a CSV file; existing file is overwritten.
.PARAMETER ComputerName
    Name of the computer from which to export the printers.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER ExportFile
    Path and filename of the CSV file to export.
.PARAMETER Delimiter
    Delimiter that separates the property values in the CSV file.
.PARAMETER FileEncoding
    Type of character encoding used in the CSV file.
.PARAMETER IncludeTcpIpPortProperties
    Export the TCP/IP port address and number.
.EXAMPLE
    PS> ./Export-Printers.ps1 -ExportFile 'C:\Temp\printers.csv'
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
    [pscredential]$AccessAccount,
    [switch]$IncludeTcpIpPortProperties
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $props = @('Name', 'DriverName', 'PortName', 'Shared', 'Sharename', 'Comment', 'Location', 'Datatype', 'PrintProcessor', 'RenderingMode')
        $printers = Get-Printer -Full -CimSession $cim -ComputerName $ComputerName -ErrorAction Stop |
            Where-Object { $_.Type -eq 'Local' } | Select-Object $props | Sort-Object Name
        $msgs = @()
        $csv = foreach ($p in $printers) {
            $row = [ordered]@{
                ComputerName = $ComputerName
                PrinterName = $p.Name
                PrinterDriver = $p.DriverName
                PortAddress = $p.PortName
                PortNumber = ''
                Shared = $p.Shared
                DifferentShareName = ''
                Comment = $p.Comment
                Location = $p.Location
                Datatype = $p.DataType
                PrintProcessor = $p.PrintProcessor
                RenderingMode = $p.RenderingMode
            }
            if ($p.Shared -and $p.Sharename -ne $p.Name) { $row.DifferentShareName = $p.Sharename }
            if ($IncludeTcpIpPortProperties) {
                try {
                    $port = Get-PrinterPort -CimSession $cim -Name $p.PortName -ComputerName $ComputerName -ErrorAction SilentlyContinue
                    if ($null -ne $port.PrinterHostAddress) {
                        $row.PortAddress = $port.PrinterHostAddress
                        if ($null -ne $port.PortNumber) { $row.PortNumber = $port.PortNumber }
                    }
                }
                catch { $msgs += "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") Error getting printer port $($p.PortName): $($_.Exception.Message)" }
            }
            [PSCustomObject]$row
        }
        $csv | Export-Csv -Path $ExportFile -Delimiter $Delimiter -Encoding $FileEncoding -Force -NoTypeInformation -ErrorAction Stop
        Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") Printers exported to: $ExportFile"
        if ($msgs.Count -gt 0) { Write-Output $msgs }
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
