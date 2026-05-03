#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Configures network protocols for a SQL Server instance

.DESCRIPTION
    Sets the network configuration (currently supports TCP) for a specified SQL Server instance. This script allows enabling/disabling protocols, configuring ports, and managing service restarts.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.
    
.PARAMETER Protocol
    Specifies the network protocol to configure (Currently only 'TCP' is supported by this script)

.PARAMETER AutomaticallyAcceptUntrustedCertificates
    Indicates that this cmdlet automatically accepts untrusted certificates

.PARAMETER Disable
    Indicates that this cmdlet disables the specified network protocol

.PARAMETER ForceServiceRestart
    Indicates that this cmdlet forces the SQL Server service to restart, if necessary, without prompting the user

.PARAMETER ManagementPublicPort
    Specifies the public management port on the target computer

.PARAMETER NoServiceRestart
    Indicates that this cmdlet prevents a restart of the SQL Server service without prompting the user

.PARAMETER Port
    Specifies the port to accept TCP connections. To configure dynamic ports, set this parameter to 0.

.PARAMETER RetryTimeout
    Specifies the time period to retry the command on the target sever

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Set-NetworkConfiguration.ps1 -ServerInstance "localhost\SQLEXPRESS" -Protocol TCP -Port 1433 -ForceServiceRestart

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [pscredential]$ServerCredential,
    [ValidateSet('TCP')]
    [string]$Protocol = "TCP",
    [switch]$AutomaticallyAcceptUntrustedCertificates,
    [switch]$Disable,
    [switch]$ForceServiceRestart,
    [int]$ManagementPublicPort,
    [switch]$NoServiceRestart, 
    [int]$Port = 0,   
    [int]$RetryTimeout,
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

    [hashtable]$setArgs = @{
        'ErrorAction' = 'Stop'
        'InputObject'  = $instance
        'AutomaticallyAcceptUntrustedCertificates' = $AutomaticallyAcceptUntrustedCertificates.ToBool()
        'Protocol'     = $Protocol
        'Disable'      = $Disable.ToBool()
        'ForceServiceRestart' = $ForceServiceRestart.ToBool()
        'NoServiceRestart' = $NoServiceRestart.ToBool()
        'Port'         = $Port
        'Credential'   = $ServerCredential
        'Confirm'      = $false
    }                               
    if ($ManagementPublicPort -gt 0) {
        $setArgs.Add('ManagementPublicPort', $ManagementPublicPort)
    }
    if ($RetryTimeout -gt 0) {
        $setArgs.Add('RetryTimeout', $RetryTimeout)
    }    

    $result = Set-SqlNetworkConfiguration @setArgs | Select-Object *    
    Write-Output $result
} catch {
    throw
}
