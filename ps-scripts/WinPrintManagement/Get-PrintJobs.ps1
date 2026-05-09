#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Retrieves all print jobs on the specified printer.
.DESCRIPTION
    Retrieves a list of print jobs from the specified printer using the PrintManagement module.
.PARAMETER ComputerName
    Name of the computer from which to retrieve the print jobs.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER PrinterName
    Name of the printer from which to retrieve the print jobs.
.PARAMETER Properties
    List of properties to expand; use * for all properties.
.EXAMPLE
    PS> ./Get-PrintJobs.ps1 -ComputerName "PC01" -PrinterName "MyPrinter"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [string]$ComputerName,
    [pscredential]$AccessAccount,
    [ValidateSet('*', 'ID', 'JobStatus', 'DocumentName', 'UserName', 'Position', 'Size', 'PagesPrinted', 'TotalPages', 'SubmittedTime', 'Priority')]
    [string[]]$Properties = @('ID', 'JobStatus', 'DocumentName', 'UserName', 'Position', 'Size', 'PagesPrinted', 'TotalPages', 'SubmittedTime', 'Priority')
)

Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        elseif ($null -eq ($Properties | Where-Object { $_ -like 'ID' })) { $Properties += 'ID' }
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $jobs = Get-PrintJob -CimSession $cim -PrinterName $PrinterName -ComputerName $ComputerName -ErrorAction Stop |
            Select-Object $Properties | Sort-Object ID
        $jobs | ForEach-Object { $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru }
        Write-Output $jobs
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
