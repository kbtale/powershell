#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Configures Windows Automatic Logon settings

.DESCRIPTION
    Sets the registry keys required for Windows to automatically log on a specific user at startup. Supports local and remote systems.

.PARAMETER Enabled
    Specifies whether to enable or disable automatic logon.

.PARAMETER UserName
    Specifies the username for automatic logon.

.PARAMETER DomainName
    Specifies the domain name or computer name for the user account.

.PARAMETER Password
    Specifies the password for the user account as a secure string.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-AutoLogonConfig.ps1 -Enabled $true -UserName "Admin" -Password (Read-Host -AsSecureString)

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [bool]$Enabled,

    [string]$UserName,

    [string]$DomainName,

    [securestring]$Password,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($IsEnabled, $User, $Domain, $Pass)
            $logonValue = if ($IsEnabled) { "1" } else { "0" }
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
            
            Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value $logonValue -Force -ErrorAction Stop
            
            if ($IsEnabled) {
                if (-not $User) { throw "UserName is required to enable AutoLogon" }
                Set-ItemProperty -Path $regPath -Name "DefaultUserName" -Value $User -Force -ErrorAction Stop
                if ($Domain) {
                    Set-ItemProperty -Path $regPath -Name "DefaultDomainName" -Value $Domain -Force -ErrorAction Stop
                }
                if ($Pass) {
                    $passStr = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Pass))
                    Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value $passStr -Force -ErrorAction Stop
                }
            }
            else {
                Remove-ItemProperty -Path $regPath -Name "DefaultPassword" -ErrorAction SilentlyContinue
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Enabled, $UserName, $DomainName, $Password)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
        }
        else {
            &$scriptBlock -IsEnabled $Enabled -User $UserName -Domain $DomainName -Pass $Password
        }

        $result = [PSCustomObject]@{
            AutoLogonEnabled = $Enabled
            UserName         = $UserName
            ComputerName     = $ComputerName
            Action           = "AutoLogonConfigured"
            Status           = "Success"
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
