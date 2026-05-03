#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Creates a new SQL Server database column encryption key

.DESCRIPTION
    Creates a new column encryption key (CEK) within a SQL Server database. This script provides a standardized way to define encryption keys for Always Encrypted, specifying the associated column master key and optional encrypted value.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER DatabaseName 
    Specifies the name of the SQL database where the key will be created

.PARAMETER ColumnMasterKeyName
    Specifies the name of the column master key to be used with this column encryption key

.PARAMETER KeyName
    Specifies the name of the new column encryption key object

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER EncryptedValue
    Specifies the encrypted value of the column encryption key

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./New-ColumnEncryptionKey.ps1 -ServerInstance "localhost\SQLEXPRESS" -DatabaseName "SalesDB" -ColumnMasterKeyName "MyCMK" -KeyName "MyCEK"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName,    
    [Parameter(Mandatory = $true)]   
    [string]$ColumnMasterKeyName ,    
    [Parameter(Mandatory = $true)]  
    [string]$KeyName,
    [pscredential]$ServerCredential,
    [string]$EncryptedValue,
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

    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'InputObject' = $db
        'ColumnMasterKeyName' = $ColumnMasterKeyName
        'Name' = $KeyName
    }
    if (-not [string]::IsNullOrWhiteSpace($EncryptedValue)) {
        $cmdArgs.Add("EncryptedValue", $EncryptedValue)
    }

    $result = New-SqlColumnEncryptionKey @cmdArgs | Select-Object *
    Write-Output $result
} catch {
    throw
}
