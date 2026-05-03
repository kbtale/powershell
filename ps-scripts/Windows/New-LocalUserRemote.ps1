#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Creates a new local user account on a computer

.DESCRIPTION
    Creates a new local user account on a local or remote machine. Supports configuring passwords, full names, and account expiration policies.

.PARAMETER Name
    Specifies the user name for the new account.

.PARAMETER FullName
    Specifies the full name for the user account.

.PARAMETER Description
    Specifies a description for the user account.

.PARAMETER Password
    Specifies a secure string used as the initial password.

.PARAMETER PasswordNeverExpires
    If set, the password for the account will never expire.

.PARAMETER Disabled
    If set, creates the account in a disabled state.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./New-LocalUserRemote.ps1 -Name "User01" -Password (Read-Host -AsSecureString)

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$FullName,

    [string]$Description,

    [securestring]$Password,

    [switch]$PasswordNeverExpires,

    [switch]$Disabled,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($UserName, $UserFull, $UserDesc, $UserPass, $PassNever, $IsDisabled)
            $params = @{
                'Name' = $UserName
                'Confirm' = $false
                'ErrorAction' = 'Stop'
            }
            if ($UserFull) { $params.Add('FullName', $UserFull) }
            if ($UserDesc) { $params.Add('Description', $UserDesc) }
            if ($UserPass) { 
                $params.Add('Password', $UserPass)
                if ($PassNever) { $params.Add('PasswordNeverExpires', $true) }
            }
            else {
                $params.Add('NoPassword', $true)
            }
            if ($IsDisabled) { $params.Add('Disabled', $true) }
            
            New-LocalUser @params
            Get-LocalUser -Name $UserName | Select-Object Name, SID, Enabled, Description
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Name, $FullName, $Description, $Password, $PasswordNeverExpires, $Disabled)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -UserName $Name -UserFull $FullName -UserDesc $Description -UserPass $Password -PassNever $PasswordNeverExpires -IsDisabled $Disabled
        }

        $output = [PSCustomObject]@{
            Name         = $result.Name
            SID          = $result.SID.Value
            Enabled      = $result.Enabled
            Description  = $result.Description
            ComputerName = $ComputerName
            Action       = "UserCreated"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
