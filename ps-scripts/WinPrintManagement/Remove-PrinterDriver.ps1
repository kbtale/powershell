#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Deletes a printer driver from the specified computer.
.DESCRIPTION
    Removes a printer driver from the specified computer using the PrintManagement module.
.PARAMETER ComputerName
    Name of the computer from which to remove the printer driver.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER DriverName
    Name of the printer driver to remove.
.PARAMETER RemoveFromDriverStore
    Remove the printer driver from the driver store.
.EXAMPLE
    PS> ./Remove-PrinterDriver.ps1 -ComputerName "PC01" -DriverName "HP Universal Printing PCL 6"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$DriverName,
    [string]$ComputerName,
    [pscredential]$AccessAccount,
    [switch]$RemoveFromDriverStore
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        if ($RemoveFromDriverStore) {
            Remove-PrinterDriver -CimSession $cim -Name $DriverName -ComputerName $ComputerName -RemoveFromDriverStore -ErrorAction Stop | Out-Null
        }
        else {
            Remove-PrinterDriver -CimSession $cim -Name $DriverName -ComputerName $ComputerName -ErrorAction Stop | Out-Null
        }
        Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") Printer driver $DriverName removed from $ComputerName"
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
