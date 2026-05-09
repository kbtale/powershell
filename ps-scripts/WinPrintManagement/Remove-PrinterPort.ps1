#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Removes the specified printer port from the specified computer.
.DESCRIPTION
    Removes a printer port from the specified computer using the PrintManagement module.
.PARAMETER ComputerName
    Name of the computer from which to remove the printer port.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER PortName
    Name of the printer port to remove.
.EXAMPLE
    PS> ./Remove-PrinterPort.ps1 -ComputerName "PC01" -PortName "LPT1:"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PortName,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        Remove-PrinterPort -CimSession $cim -ComputerName $ComputerName -Name $PortName -ErrorAction Stop | Out-Null
        Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") Printer port $PortName removed from $ComputerName"
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
