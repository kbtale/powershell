#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Gets local printers from the specified computer.
.DESCRIPTION
    Retrieves all local printers from the specified computer using the PrintManagement module.
.PARAMETER ComputerName
    Name of the computer from which to retrieve the printers.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER IncludeTcpIpPortProperties
    Include the TCP/IP port address and number in the output.
.EXAMPLE
    PS> ./Get-Printers.ps1 -ComputerName "PC01"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
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
        $tsVal = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $output = foreach ($p in $printers) {
            $row = [PSCustomObject]@{
                Timestamp = $tsVal
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
                catch { }
            }
            $row
        }
        Write-Output $output
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
