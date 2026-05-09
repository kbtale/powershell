#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Sets printer permissions
.DESCRIPTION
    Grants permissions to a user or group on a printer.
.PARAMETER PrinterName
    Printer to set permissions on
.PARAMETER UserName
    User or group to grant permissions to
.PARAMETER AccessMask
    Access level: Print, ManagePrinters, ManageDocuments
.PARAMETER Allow
    Allow or deny access
.PARAMETER ComputerName
    Computer hosting the printer
.PARAMETER AccessAccount
    Optional credential
.EXAMPLE
    PS> ./Set-PrinterPermissions.ps1 -PrinterName "HP LaserJet" -UserName "DOMAIN\Group" -AccessMask Print -Allow $true
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][string]$PrinterName,
    [Parameter(Mandatory = $true)][string]$UserName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Print', 'ManagePrinters', 'ManageDocuments')][string]$AccessMask,
    [bool]$Allow = $true,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop } else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $sd = Get-PrinterProperty -CimSession $cim -ComputerName $ComputerName -PrinterName $PrinterName -PropertyName SecurityDescriptor -ErrorAction Stop
        $acl = $sd.SecurityDescriptor
        $ace = New-Object System.Security.AccessControl.AccessRule($UserName, $AccessMask, $Allow, 'None', 'None')
        $acl.AddAccessRule($ace)
        Set-PrinterProperty -CimSession $cim -ComputerName $ComputerName -PrinterName $PrinterName -PropertyName SecurityDescriptor -Value $acl -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; PrinterName = $PrinterName; UserName = $UserName; AccessMask = $AccessMask; Allow = $Allow.ToString(); Message = "Permissions set for '$UserName'" }
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
