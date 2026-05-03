#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Creates a new SQL Server credential object

.DESCRIPTION
    Creates a new credential object on a SQL Server instance. This script provides a standardized way to define external identities and their secrets for use in proxy accounts and other server-level features.

.PARAMETER Name
    Specifies the name of the new SQL Server credential

.PARAMETER Identity
    Specifies the name of the user or account for the credential

.PARAMETER Password
    Specifies the password for the account as a SecureString

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> $pwd = Read-Host -AsSecureString
    PS> ./New-Credential.ps1 -Name "MyBackupUser" -Identity "CONTOSO\BackupSvc" -Password $pwd -ServerInstance "localhost\SQLEXPRESS"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$Name,    
    [Parameter(Mandatory = $true)]   
    [string]$Identity,       
    [Parameter(Mandatory = $true)]   
    [securestring]$Password,
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
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

Import-Module SQLServer

try {
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'Name'        = $Name
        'Identity'    = $Identity
        'InputObject' = $instance
        'Secret'      = $Password
        'Confirm'     = $false
    }    
       
    $result = New-SqlCredential @cmdArgs | Select-Object *
    Write-Output $result
} catch {
    throw
}
