#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Configures column encryption for a SQL Server database

.DESCRIPTION
    Encrypts, decrypts, or re-encrypts specified columns in a SQL Server database using Always Encrypted. This script reads encryption settings from a CSV file and applies them, supporting both online and offline approaches.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER DatabaseName
    Specifies the name of the SQL database to modify

.PARAMETER SettingsCsvFile
    Specifies the path to a CSV file containing the encryption settings. 
    Required columns: ColumnName (e.g. Table.Col), EncryptionType (Deterministic, Randomized, or Plaintext), EncryptionKey (Name of CEK)

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER KeepCheckForeignKeyConstraints
    If set, check semantics of foreign key constraints are preserved

.PARAMETER LogFileDirectory
    If set, a log file will be created in the specified directory

.PARAMETER MaxDivergingIterations
    Specifies the maximum number of consecutive catch-up iterations allowed before failing

.PARAMETER MaxDowntimeInSeconds
    Specifies the maximum downtime (in seconds) allowed for the source table

.PARAMETER MaxIterationDurationInDays
    Specifies the maximum time (in days) for a single iteration

.PARAMETER MaxIterations
    Specifies the maximum number of iterations in the catch-up phase

.PARAMETER UseOnlineApproach
    If set, the cmdlet will use the online approach to minimize downtime

.PARAMETER CsvDelimiter
    Specifies the delimiter used in the CSV file (defaults to ';')

.PARAMETER FileEncoding
    Specifies the character encoding of the CSV file (defaults to 'UTF8')

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Set-ColumnEncryption.ps1 -ServerInstance "localhost\SQLEXPRESS" -DatabaseName "SalesDB" -SettingsCsvFile "C:\Config\Encryption.csv"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,     
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName,    
    [Parameter(Mandatory = $true)]   
    [string]$SettingsCsvFile,
    [pscredential]$ServerCredential,
    [switch]$KeepCheckForeignKeyConstraints,
    [string]$LogFileDirectory,
    [int]$MaxDivergingIterations,
    [int]$MaxDowntimeInSeconds,
    [int]$MaxIterationDurationInDays,
    [int]$MaxIterations,
    [switch]$UseOnlineApproach,
    [string]$CsvDelimiter = ';',
    [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
    [string]$FileEncoding = 'UTF8',
    [int]$ConnectionTimeout = 30
)

function Get-SqlServerInstanceInternal {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $true)]   
        [string]$ServerInstance,    
        [pscredential]$ServerCredential,
        [int]$ConnectionTimeout = 30
    )
    try {
        [hashtable]$cmdArgs = @{
            'ErrorAction' = 'Stop'
            'Confirm' = $false
            'ServerInstance' = $ServerInstance
            'ConnectionTimeout' = $ConnectionTimeout
        }
        if ($null -ne $ServerCredential) {
            $cmdArgs.Add('Credential', $ServerCredential)
        }
        return Get-SqlInstance @cmdArgs
    } catch {
        throw
    }
}

function Get-SqlDatabaseInternal {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $true)]   
        [object]$ServerInstance,    
        [Parameter(Mandatory = $true)]   
        [string]$DatabaseName
    )
    try {
        [hashtable]$cmdArgs = @{
            'ErrorAction' = 'Stop'
            'InputObject' = $ServerInstance
            'Name' = $DatabaseName
            'Confirm' = $false
        }
        return Get-SqlDatabase @cmdArgs
    } catch {
        throw
    }
}

Import-Module SQLServer

try {
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout
    $db = Get-SqlDatabaseInternal -DatabaseName $DatabaseName -ServerInstance $instance

    if (-not (Test-Path -Path $SettingsCsvFile)) {
        throw "CSV file not found: $SettingsCsvFile"
    }
    
    $settings = Import-Csv -Path $SettingsCsvFile -Delimiter $CsvDelimiter -Encoding $FileEncoding -Header @('ColumnName', 'EncryptionType', 'EncryptionKey') -ErrorAction Stop
    
    $colEncry = @()
    foreach ($item in $settings) {
        if ($item.EncryptionType -eq 'EncryptionType' -or [string]::IsNullOrWhiteSpace($item.ColumnName)) {
            continue
        }
        
        $setParams = @{
            'ColumnName'     = $item.ColumnName
            'EncryptionType' = $item.EncryptionType
        }
        if ($item.EncryptionType -ne 'Plaintext' -and -not [string]::IsNullOrWhiteSpace($item.EncryptionKey)) {
            $setParams.Add('EncryptionKey', $item.EncryptionKey)
        }
        
        $colEncry += New-SqlColumnEncryptionSettings @setParams
    }
    
    if ($colEncry.Count -eq 0) {
        throw "No valid encryption settings found in CSV file."
    }

    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'ColumnEncryptionSettings' = $colEncry
        'InputObject' = $db                            
    }    
    
    if (-not [string]::IsNullOrWhiteSpace($LogFileDirectory)) {
        $cmdArgs.Add('LogFileDirectory', $LogFileDirectory)
    }
    
    if ($UseOnlineApproach) {
        $cmdArgs.Add('UseOnlineApproach', $true)
        $cmdArgs.Add('KeepCheckForeignKeyConstraints', $KeepCheckForeignKeyConstraints.ToBool())
        if ($MaxIterations -gt 0) { $cmdArgs.Add('MaxIterations', $MaxIterations) }
        if ($MaxDowntimeInSeconds -gt 0) { $cmdArgs.Add('MaxDowntimeInSeconds', $MaxDowntimeInSeconds) }
        if ($MaxIterationDurationInDays -gt 0) { $cmdArgs.Add('MaxIterationDurationInDays', $MaxIterationDurationInDays) }
        if ($MaxDivergingIterations -gt 0) { $cmdArgs.Add('MaxDivergingIterations', $MaxDivergingIterations) }
    }

    $result = Set-SqlColumnEncryption @cmdArgs | Select-Object *    
    Write-Output $result
} catch {
    throw
}
