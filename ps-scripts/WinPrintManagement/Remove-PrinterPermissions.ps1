#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Removes printer permissions
.DESCRIPTION
    Removes user permissions from a printer.
.PARAMETER PrinterName
    Printer to modify permissions on
.PARAMETER UserName
    User or group to remove permissions for
.PARAMETER ComputerName
    Computer hosting the printer
.PARAMETER AccessAccount
    Optional credential
.EXAMPLE
    PS> ./Remove-PrinterPermissions.ps1 -PrinterName "HP LaserJet" -UserName "DOMAIN\User"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][string]$PrinterName,
    [Parameter(Mandatory = $true)][string]$UserName,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop } else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $sd = Get-PrinterProperty -CimSession $cim -ComputerName $ComputerName -PrinterName $PrinterName -PropertyName SecurityDescriptor -ErrorAction Stop
        $acl = $sd.SecurityDescriptor
        $acl.Access = $acl.Access | Where-Object { $_.IdentityReference -ne $UserName }
        Set-PrinterProperty -CimSession $cim -ComputerName $ComputerName -PrinterName $PrinterName -PropertyName SecurityDescriptor -Value $acl -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; PrinterName = $PrinterName; UserName = $UserName; Message = "Permissions removed for '$UserName'" }
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
