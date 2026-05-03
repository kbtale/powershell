#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Runs a script containing statements supported by the SQL Server SQLCMD utility

.DESCRIPTION
    Executes Transact-SQL or XQuery statements, or sqlcmd commands. This script supports both direct query strings and input files, with advanced options for encryption, timeout, and error handling.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER Query
    Specifies one or more queries that this cmdlet runs. The queries can be Transact-SQL or XQuery statements, or sqlcmd commands    

.PARAMETER File
    Specifies a file to be used as the query input to this cmdlet

.PARAMETER QueryTimeout
    Specifies the number of seconds before the queries time out

.PARAMETER AbortOnError
    Indicates that this cmdlet stops the SQL Server command and returns an error level if this cmdlet encounters an error

.PARAMETER DatabaseName
    Specifies the name of a database

.PARAMETER EncryptConnection
    Indicates that this cmdlet uses Secure Sockets Layer (SSL) encryption for the connection to the Database Engine

.PARAMETER DisableVariables
    Indicates that this cmdlet ignores sqlcmd scripting variables

.PARAMETER DisableCommands
    Indicates that this cmdlet turns off some sqlcmd features that might compromise security when run in batch files

.PARAMETER DedicatedAdministratorConnection
    Indicates that this cmdlet uses a Dedicated Administrator Connection (DAC) to connect to the Database Engine

.PARAMETER OutputSqlErrors
    Indicates that this cmdlet displays error messages in the output

.PARAMETER IncludeSqlUserErrors
    Indicates that this cmdlet returns SQL user script errors that are otherwise ignored by default

.PARAMETER ErrorLevel
    Specifies that this cmdlet display only error messages whose severity level is equal to or higher than the value specified

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Invoke-Cmd.ps1 -ServerInstance "localhost\SQLEXPRESS" -DatabaseName "Master" -Query "SELECT name FROM sys.databases"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Query')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'File')]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true,ParameterSetName = "Query")]   
    [Parameter(Mandatory = $true,ParameterSetName = "File")]   
    [string]$DatabaseName,   
    [Parameter(Mandatory = $true, ParameterSetName = 'Query')]   
    [string]$Query,
    [Parameter(Mandatory = $true, ParameterSetName = 'File')]   
    [string]$File,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]         
    [ValidateRange(1,65535)]
    [int]$QueryTimeout ,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [pscredential]$ServerCredential,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$AbortOnError,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$EncryptConnection,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$DisableCommands,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$DisableVariables,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$DedicatedAdministratorConnection,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [bool]$OutputSqlErrors,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$IncludeSqlUserErrors,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [ValidateRange(1,24)]
    [int]$ErrorLevel ,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
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
        'ServerInstance' = $instance
        'Database' = $DatabaseName
        'DisableCommands' = $DisableCommands.ToBool()
        'DisableVariables' = $DisableVariables.ToBool()                            
        'EncryptConnection' = $EncryptConnection.ToBool()
        'AbortOnError' = $AbortOnError.ToBool()
        'OutputSqlErrors' = $OutputSqlErrors
        'DedicatedAdministratorConnection' = $DedicatedAdministratorConnection.ToBool()
        'IncludeSqlUserErrors' = $IncludeSqlUserErrors.ToBool()
    }
    
    if ($ErrorLevel -gt 0) {        
        $cmdArgs.Add("ErrorLevel", $ErrorLevel)
    }
    if ($QueryTimeout -gt 0) {        
        $cmdArgs.Add("QueryTimeout", $QueryTimeout)
    }
    
    if ($PSCmdlet.ParameterSetName -eq "Query") {
        $cmdArgs.Add("Query", $Query)
    } else {      
        $cmdArgs.Add("InputFile", $File)
    }
    
    $result = Invoke-Sqlcmd @cmdArgs
    Write-Output $result
} catch {
    throw
}
