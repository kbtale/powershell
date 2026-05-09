#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Retrieves the print job on the specified printer.
.DESCRIPTION
    Retrieves a specific print job by ID from the specified printer using the PrintManagement module.
.PARAMETER ComputerName
    Name of the computer from which to retrieve the print job.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER PrinterName
    Name of the printer from which to retrieve the print job.
.PARAMETER JobID
    ID of the print job to retrieve.
.PARAMETER Properties
    List of properties to expand; use * for all properties.
.EXAMPLE
    PS> ./Get-PrintJob.ps1 -ComputerName "PC01" -PrinterName "MyPrinter" -JobID 5
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [Parameter(Mandatory = $true)]
    [int]$JobID,
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
        $job = Get-PrintJob -CimSession $cim -PrinterName $PrinterName -ComputerName $ComputerName -ID $JobID -ErrorAction Stop |
            Select-Object $Properties | Sort-Object ID
        $job | ForEach-Object { $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru }
        Write-Output $job
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
