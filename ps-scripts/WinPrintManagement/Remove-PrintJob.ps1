#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Removes a print job on the specified printer.
.DESCRIPTION
    Removes a specific print job from the specified printer using the PrintManagement module.
.PARAMETER ComputerName
    Name of the computer from which to remove the print job.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER PrinterName
    Name of the printer from which to remove the print job.
.PARAMETER JobID
    ID of the print job to remove.
.EXAMPLE
    PS> ./Remove-PrintJob.ps1 -ComputerName "PC01" -PrinterName "MyPrinter" -JobID 5
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [Parameter(Mandatory = $true)]
    [int]$JobID,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        Remove-PrintJob -CimSession $cim -ComputerName $ComputerName -PrinterName $PrinterName -ID $JobID -ErrorAction Stop | Out-Null
        Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") Print job $JobID removed from printer $PrinterName on $ComputerName"
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
