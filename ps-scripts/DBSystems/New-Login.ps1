#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Creates a new Login in a SQL Server instance

.DESCRIPTION
    Creates a new SQL Server login. Supports multiple login types including SQL Login, Windows User/Group, and certificate-based authentication. 
    Includes options for enforcing password policies and granting initial connect permissions.

.PARAMETER LoginCredential
    Specifies a PSCredential object that allows the Login object to provide name and password without a prompt

.PARAMETER LoginType
    Specifies the type of the Login object

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER DefaultDatabase
    Specify the default database for the Login object

.PARAMETER Enable
    Indicates that the Login object is enabled. By default, Login objects are disabled

.PARAMETER EnforcePasswordExpiration
    Indicates that the password expiration policy is enforced for the Login object
        
.PARAMETER EnforcePasswordPolicy
    Indicates that the password policy is enforced for the Login object

.PARAMETER MustChangePasswordAtNextLogin
    Indicates that the user must change the password at the next login

.PARAMETER GrantConnectSql
    Indicates that the Login object is not denied permissions to connect to the database engine. 
    By default, Login objects are denied permissions to connect to the database engine

.PARAMETER AsymmetricKey
    Specify the name of the asymmetric key for the Login object

.PARAMETER Certificate
    Specify the name of the certificate for the Login object

.PARAMETER CredentialName
    Specify the name of the credential for the Login object

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./New-Login.ps1 -ServerInstance "localhost\SQLEXPRESS" -LoginType SqlLogin -LoginCredential (Get-Credential) -Enable -GrantConnectSql

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$LoginCredential,
    [Parameter(Mandatory = $true)]   
    [ValidateSet('WindowsUser', 'WindowsGroup', 'SqlLogin', 'Certificate', 'AsymmetricKey')]
    [string]$LoginType = "SqlLogin",
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$DefaultDatabase,
    [switch]$Enable,
    [switch]$EnforcePasswordExpiration,
    [switch]$EnforcePasswordPolicy,
    [switch]$MustChangePasswordAtNextLogin,
    [switch]$GrantConnectSql,
    [string]$AsymmetricKey,
    [string]$Certificate,
    [SecureString]$CredentialName,
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
    $Properties = @('Name','Status','LoginType','Language','IsLocked','IsDisabled','IsPasswordExpired','MustChangePassword','PasswordExpirationEnabled','HasAccess','State')
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'LoginType' = $LoginType
        'InputObject' = $instance
        'Enable' = $Enable.ToBool()
        "LoginPSCredential" = $LoginCredential
        'GrantConnectSql' = $GrantConnectSql.ToBool()
    }
    
    if ($LoginType -eq "SqlLogin") {
        $cmdArgs.Add("EnforcePasswordExpiration", $EnforcePasswordExpiration.ToBool())
        $cmdArgs.Add("EnforcePasswordPolicy", $EnforcePasswordPolicy.ToBool())
        $cmdArgs.Add("MustChangePasswordAtNextLogin", $MustChangePasswordAtNextLogin.ToBool())
    } 
    
    if (-not [string]::IsNullOrWhiteSpace($DefaultDatabase)) {        
        $cmdArgs.Add("DefaultDatabase", $DefaultDatabase)
    }
    if (-not [string]::IsNullOrWhiteSpace($AsymmetricKey)) {        
        $cmdArgs.Add("AsymmetricKey", $AsymmetricKey)
    }
    if (-not [string]::IsNullOrWhiteSpace($Certificate)) {        
        $cmdArgs.Add("Certificate", $Certificate)
    }
    if ($null -ne $CredentialName) {
        $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($CredentialName)
        try {
            $plainName = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr)
            $cmdArgs.Add("CredentialName", $plainName)
        } finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
        }
    }
       
    $result = Add-SqlLogin @cmdArgs | Select-Object $Properties
    Write-Output $result
} catch {
    throw
}
