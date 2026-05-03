#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Modifies a local user account configuration

.DESCRIPTION
    Updates properties of an existing local user account on a local or remote machine. Supports modifying full name, description, password, and account policies.

.PARAMETER Name
    Specifies the name of the local user to modify.

.PARAMETER FullName
    Specifies a new full name for the user account.

.PARAMETER Description
    Specifies a new description for the user account.

.PARAMETER Password
    Specifies a new secure string password for the account.

.PARAMETER PasswordNeverExpires
    If set, the password for the account will never expire.

.PARAMETER AccountNeverExpires
    If set, the account will never expire.

.PARAMETER Enabled
    If set, enables or disables the account.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-LocalUserConfig.ps1 -Name "User01" -FullName "Updated Name"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$FullName,

    [string]$Description,

    [securestring]$Password,

    [bool]$PasswordNeverExpires,

    [bool]$AccountNeverExpires,

    [bool]$Enabled,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($UserName, $UserFull, $UserDesc, $UserPass, $PassNever, $AccNever, $IsEnabled, $BoundParams)
            $params = @{
                'Name' = $UserName
                'ErrorAction' = 'Stop'
            }
            if ($BoundParams.ContainsKey('FullName')) { $params.Add('FullName', $UserFull) }
            if ($BoundParams.ContainsKey('Description')) { $params.Add('Description', $UserDesc) }
            if ($BoundParams.ContainsKey('Password')) { $params.Add('Password', $UserPass) }
            if ($BoundParams.ContainsKey('PasswordNeverExpires')) { $params.Add('PasswordNeverExpires', $PassNever) }
            if ($BoundParams.ContainsKey('AccountNeverExpires')) { $params.Add('AccountNeverExpires', $AccNever) }
            if ($BoundParams.ContainsKey('Enabled')) { $params.Add('Enabled', $IsEnabled) }
            
            Set-LocalUser @params
            Get-LocalUser -Name $UserName | Select-Object Name, SID, Enabled, Description
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Name, $FullName, $Description, $Password, $PasswordNeverExpires, $AccountNeverExpires, $Enabled, $PSBoundParameters)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -UserName $Name -UserFull $FullName -UserDesc $Description -UserPass $Password -PassNever $PasswordNeverExpires -AccNever $AccountNeverExpires -IsEnabled $Enabled -BoundParams $PSBoundParameters
        }

        $output = [PSCustomObject]@{
            Name         = $result.Name
            SID          = $result.SID.Value
            Enabled      = $result.Enabled
            ComputerName = $ComputerName
            Action       = "UserModified"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
