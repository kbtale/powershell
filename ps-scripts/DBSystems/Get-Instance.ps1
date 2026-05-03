#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets SQL Server instance information

.DESCRIPTION
    Retrieves detailed information about a SQL Server instance, including its status, edition, and configuration settings.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.PARAMETER Properties
    List of properties to expand, comma separated e.g. Edition,Status. Use * for all properties

.EXAMPLE
    PS> ./Get-Instance.ps1 -ServerInstance "localhost\SQLEXPRESS" -Properties Edition,Status

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [int]$ConnectionTimeout = 30,
    [Validateset('*','DisplayNameOrName','Status','Edition','InstanceName','DomainInstanceName','LoginMode','ServerType','ServiceStartMode','ComputerNamePhysicalNetBIOS')]
    [string[]]$Properties = @('DisplayNameOrName','Status','Edition','InstanceName','DomainInstanceName','LoginMode','ServerType','ServiceStartMode','ComputerNamePhysicalNetBIOS')
)

Import-Module SQLServer

try {
    if ($Properties -contains '*') {
        $Properties = @('*')
    }
    
    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'Confirm' = $false
        'ServerInstance' = $ServerInstance
        'ConnectionTimeout' = $ConnectionTimeout
    }

    if ($null -ne $ServerCredential) {
        $cmdArgs.Add('Credential', $ServerCredential)
    }
    
    $result = Get-SqlInstance @cmdArgs | Select-Object $Properties
    Write-Output $result
} catch {
    throw
}
