#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Creates a new printer
.DESCRIPTION
    Creates a print port and printer on the specified computer with configurable settings.
.PARAMETER PrinterName
    Name of the printer to create
.PARAMETER DriverName
    Printer driver name
.PARAMETER ComputerName
    Target computer
.PARAMETER Shared
    Share the printer on the network
.PARAMETER DifferentSharename
    Alternative share name
.PARAMETER PortAddress
    Port address (default LPT1:)
.PARAMETER PortNumber
    TCP/IP port number
.PARAMETER Comment
    Printer comment
.PARAMETER Location
    Printer location
.PARAMETER AccessAccount
    Optional credential
.EXAMPLE
    PS> ./New-Printer.ps1 -PrinterName "SalesHP" -DriverName "HP Universal Printing PCL 6" -PortAddress "192.168.1.50"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [Parameter(Mandatory = $true)]
    [string]$DriverName,
    [string]$ComputerName,
    [switch]$Shared,
    [string]$DifferentSharename,
    [string]$PortAddress = 'LPT1:',
    [int]$PortNumber = 9100,
    [string]$Comment,
    [string]$Location,
    [pscredential]$AccessAccount,
    [string]$DataType = 'RAW',
    [string]$PrintProcessor = 'winprint',
    [ValidateSet('SSR', 'CSR', 'BranchOffice')]
    [string]$RenderingMode = 'SSR'
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop } else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $result = @()

        if (Get-PrinterPort -CimSession $cim -Name $PortAddress -ComputerName $ComputerName -ErrorAction SilentlyContinue) {
            $result += "Printer port '$PortAddress' already exists"
        }
        else {
            $Error.RemoveAt(0)
            $null = Add-PrinterPort -CimSession $cim -Name $PortAddress -ComputerName $ComputerName -PrinterHostAddress $PortAddress -PortNumber $PortNumber -ErrorAction Stop
            $result += "Created printer port: '$PortAddress'"
        }

        if ([System.String]::IsNullOrWhiteSpace($DifferentSharename)) { $DifferentSharename = $PrinterName }
        if (Get-Printer -CimSession $cim -Name $PrinterName -ComputerName $ComputerName -ErrorAction SilentlyContinue) {
            $result += "Printer '$PrinterName' already exists"
        }
        else {
            $Error.RemoveAt(0)
            $null = Add-Printer -CimSession $cim -ComputerName $ComputerName -Shared:$Shared.ToBool() -ShareName $DifferentSharename -Name $PrinterName -PrintProcessor $PrintProcessor -Comment $Comment -PortName $PortAddress -DriverName $DriverName -Location $Location -RenderingMode $RenderingMode -Datatype $DataType -ErrorAction Stop
            $result += "Created printer: '$PrinterName'"
        }

        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; PrinterName = $PrinterName; ComputerName = $ComputerName; Result = $result -join '; ' }
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
