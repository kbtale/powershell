#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: HTML report of printer drivers
.DESCRIPTION
    Generates an HTML report of printer drivers on the specified computer.
.PARAMETER ComputerName
    Computer to retrieve printer drivers from
.PARAMETER AccessAccount
    Optional credential for remote access
.EXAMPLE
    PS> ./Get-PrinterDrivers-Html.ps1 -ComputerName "PC01" | Out-File drivers.html
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
        $result = Get-PrinterDriver -CimSession $cim -ComputerName $ComputerName -ErrorAction Stop | Select-Object * | Sort-Object Name
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
