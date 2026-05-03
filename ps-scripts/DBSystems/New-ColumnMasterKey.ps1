#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Creates a new SQL Server database column master key

.DESCRIPTION
    Creates a new column master key (CMK) within a SQL Server database. This script provides a standardized way to define master keys for Always Encrypted using certificates from the Windows Certificate Store.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER DatabaseName 
    Specifies the name of the SQL database where the key will be created

.PARAMETER KeyName
    Specifies the name of the new column master key object

.PARAMETER CertificateStoreLocation 
    Specifies the certificate store location (CurrentUser or LocalMachine)

.PARAMETER CertificateThumbprint
    Specifies the thumbprint of the certificate to use as the master key

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./New-ColumnMasterKey.ps1 -ServerInstance "localhost\SQLEXPRESS" -DatabaseName "SalesDB" -KeyName "MyCMK" -CertificateThumbprint "A1B2C3D4..."

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName,    
    [Parameter(Mandatory = $true)]  
    [string]$KeyName,
    [Parameter(Mandatory = $true)]  
    [ValidateSet('CurrentUser','LocalMachine')]
    [string]$CertificateStoreLocation = 'LocalMachine',
    [Parameter(Mandatory = $true)]  
    [string]$CertificateThumbprint,
    [pscredential]$ServerCredential,
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

    $CmkSettings = New-SqlCertificateStoreColumnMasterKeySettings -CertificateStoreLocation $CertificateStoreLocation -Thumbprint $CertificateThumbprint -ErrorAction Stop
    $result = New-SqlColumnMasterKey -Name $KeyName -ColumnMasterKeySettings $CmkSettings -InputObject $db -ErrorAction Stop
        
    Write-Output $result
} catch {
    throw
}
