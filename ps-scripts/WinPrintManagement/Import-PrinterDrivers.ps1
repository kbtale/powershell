#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Installs printer drivers asynchronously from a CSV file.
.DESCRIPTION
    Installs printer drivers from a CSV file to a print server using asynchronous jobs.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER CsvFile
    Path and filename of the CSV file to import.
.PARAMETER Delimiter
    Delimiter that separates the property values in the CSV file.
.PARAMETER FileEncoding
    Type of character encoding used in the CSV file.
.PARAMETER MaxJobCount
    Maximum number of concurrent executed jobs.
.EXAMPLE
    PS> ./Import-PrinterDrivers.ps1 -CsvFile 'C:\Temp\drivers.csv'
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$CsvFile,
    [string]$Delimiter = ';',
    [ValidateSet('Unicode', 'UTF7', 'UTF8', 'ASCII', 'UTF32', 'BigEndianUnicode', 'Default', 'OEM')]
    [string]$FileEncoding = 'UTF8',
    [int]$MaxJobCount = 100,
    [pscredential]$AccessAccount
)

Process {
    $ts = 'Get-Date -Format "yyyy-MM-dd HH:mm:ss"'
    $err = $false
    $result = @()
    $errors = @()
    $output = @()
    $jobs = [System.Collections.Generic.Dictionary[int, string]]::new()
    $cim = $null
    try {
        if (-not (Test-Path -Path $CsvFile -ErrorAction SilentlyContinue)) { throw "$CsvFile does not exist" }
        $drivers = Import-Csv -Path $CsvFile -Delimiter $Delimiter -Encoding $FileEncoding -ErrorAction Stop `
            -Header @('DriverName', 'ComputerName', 'InfFilePath')
        foreach ($item in $drivers) {
            if ($item.ComputerName -eq 'ComputerName') { continue }
            if ([System.String]::IsNullOrWhiteSpace($item.ComputerName)) { $item.ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
            $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $item.ComputerName -ErrorAction Stop }
                   else { New-CimSession -ComputerName $item.ComputerName -Credential $AccessAccount -ErrorAction Stop }
            if (Get-PrinterDriver -CimSession $cim -Name $item.DriverName.Trim() -ComputerName $item.ComputerName -ErrorAction SilentlyContinue) {
                $output += "$(Invoke-Expression $ts) Printer driver $($item.DriverName) already exists on $($item.ComputerName)"
                Remove-CimSession $cim -ErrorAction SilentlyContinue
                continue
            }
            $Error.RemoveAt(0)
            if ([System.String]::IsNullOrWhiteSpace($item.InfFilePath)) {
                $job = Add-PrinterDriver -AsJob -CimSession $cim -Name $item.DriverName.Trim() -ComputerName $item.ComputerName
            }
            else {
                $job = Add-PrinterDriver -AsJob -CimSession $cim -Name $item.DriverName.Trim() -ComputerName $item.ComputerName -InfPath $item.InfFilePath
            }
            $jobs.Add($job.ID, $item.DriverName)
            Remove-CimSession $cim -ErrorAction SilentlyContinue
            do {
                $running = Get-Job -State Running | Where-Object { $jobs.Keys -contains $_.Id }
                if ($running -and $running.Count -gt $MaxJobCount) { Start-Sleep -Seconds 5 } else { break }
            } while ($true)
        }
        do {
            $running = Get-Job -State Running | Where-Object { $jobs.Keys -contains $_.Id }
            if ($running) { Start-Sleep -Seconds 5 } else { break }
        } while ($true)
        $completed = Get-Job | Where-Object { $jobs.Keys -contains $_.Id }
        foreach ($j in $completed) {
            if ($j.JobStateInfo.State -eq 'Failed') {
                $errors += "$(Invoke-Expression $ts) Install printer driver: $($jobs[$j.Id]) failed."
                $err = $true
            }
            if ($j.JobStateInfo.State -eq 'Completed') {
                $result += "$(Invoke-Expression $ts) Install printer driver: $($jobs[$j.Id]) succeeded."
            }
        }
        if ($err) { Write-Output $errors }
        Write-Output $result
        Write-Output $output
        if ($err) { throw "An error has occurred during import" }
    }
    catch { Write-Output $result; Write-Output $output; throw }
}
