#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Returns Login objects for a SQL Server instance

.DESCRIPTION
    Retrieves information about SQL Server logins. Includes filters for disabled, locked, or expired passwords, and supports filtering by login type (e.g., SqlLogin, WindowsUser).

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER LoginName
    Specifies the name of Login object that this cmdlet gets. Supports wildcards.

.PARAMETER OnlyDisabled
    Indicates that this cmdlet gets only disabled Login objects

.PARAMETER OnlyHasAccess
    Indicates that this cmdlet gets only Login objects that have access to the instance of SQL Server
        
.PARAMETER OnlyLocked
    Indicates that this cmdlet gets only locked Login objects

.PARAMETER OnlyPasswordExpired
    Indicates that this cmdlet gets only Login objects that have expired passwords

.PARAMETER LoginType
    Specifies the type of the Login objects that this cmdlet gets

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.PARAMETER Properties
    List of properties to expand, comma separated e.g. Name,Status. Use * for all properties

.EXAMPLE
    PS> ./Get-Login.ps1 -ServerInstance "localhost\SQLEXPRESS" -OnlyLocked

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$LoginName,
    [switch]$OnlyDisabled,
    [switch]$OnlyHasAccess,
    [switch]$OnlyLocked,
    [switch]$OnlyPasswordExpired,
    [ValidateSet('All','WindowsUser', 'WindowsGroup', 'SqlLogin', 'Certificate', 'AsymmetricKey', 'ExternalUser', 'ExternalGroup')]
    [string]$LoginType = "All",
    [int]$ConnectionTimeout = 30,
    [ValidateSet('*','Name','Status','LoginType','Language','IsLocked','IsDisabled','IsPasswordExpired','MustChangePassword','PasswordExpirationEnabled','HasAccess','State')]
    [string[]]$Properties = @('Name','Status','LoginType','Language','IsLocked','IsDisabled','IsPasswordExpired','MustChangePassword','PasswordExpirationEnabled','HasAccess','State')
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
    if ($Properties -contains '*') {
        $Properties = @('*')
    }
    
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'InputObject' = $instance
        'Disabled' = $OnlyDisabled.ToBool()
        'Locked' = $OnlyLocked.ToBool()
        'PasswordExpired' = $OnlyPasswordExpired.ToBool()
        'HasAccess' = $OnlyHasAccess.ToBool()
    }
    
    if (-not [string]::IsNullOrWhiteSpace($LoginName)) {
        $searchName = $LoginName
        if (-not $searchName.StartsWith('*')) { $searchName = '*' + $searchName }
        if (-not $searchName.EndsWith('*')) { $searchName += '*' }
        
        $cmdArgs.Add("LoginName", $searchName)
        $cmdArgs.Add("Wildcard", $null)
    }
    
    if ($LoginType -ne "All") {
        $cmdArgs.Add("LoginType", $LoginType)
    }    
    
    try {      
        $result = Get-SqlLogin @cmdArgs | Select-Object $Properties
        Write-Output $result
    } catch {
        if ($_.Exception.GetType().Name -eq "SqlPowerShellObjectNotFoundException") {
            Write-Warning "No logins found matching the criteria."
        } else {
            throw
        }
    }
} catch {
    throw
}
