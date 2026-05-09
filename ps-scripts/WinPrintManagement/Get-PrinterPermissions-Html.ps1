#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: HTML report of printer permissions
.DESCRIPTION
    Generates an HTML report of printer security permissions.
.PARAMETER PrinterName
    Name of the printer
.PARAMETER ComputerName
    Computer hosting the printer
.PARAMETER AccessAccount
    Optional credential for remote access
.EXAMPLE
    PS> ./Get-PrinterPermissions-Html.ps1 -PrinterName "HP LaserJet" | Out-File permissions.html
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop } else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $printer = Get-Printer -CimSession $cim -ComputerName $ComputerName -Name $PrinterName -ErrorAction Stop
        $acl = Get-PrinterProperty -CimSession $cim -ComputerName $ComputerName -PrinterName $PrinterName -PropertyName SecurityDescriptor -ErrorAction Stop
        $result = $acl | Select-Object -ExpandProperty SecurityDescriptor | Select-Object Owner, Group, Access
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
