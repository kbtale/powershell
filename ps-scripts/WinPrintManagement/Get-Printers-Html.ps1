#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: HTML report of printers
.DESCRIPTION
    Generates an HTML report of local printers.
.PARAMETER ComputerName
    Computer to retrieve printers from
.PARAMETER AccessAccount
    Optional credential for remote access
.EXAMPLE
    PS> ./Get-Printers-Html.ps1 -ComputerName "PC01" | Out-File printers.html
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop } else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $result = Get-Printer -Full -CimSession $cim -ComputerName $ComputerName -ErrorAction Stop | Where-Object { $_.Type -eq 'Local' } | Select-Object Name, DriverName, PortName, Shared, ShareName, Comment, Location | Sort-Object Name
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
