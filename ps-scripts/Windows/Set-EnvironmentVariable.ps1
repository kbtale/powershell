#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Sets or removes an environment variable in a specified scope

.DESCRIPTION
    Configures environment variables on a local or remote computer. Supports Machine and User scopes. Setting a variable to an empty string removes it from the scope.

.PARAMETER Name
    Specifies the name of the environment variable.

.PARAMETER Value
    Specifies the value of the environment variable. An empty string removes the variable.

.PARAMETER Scope
    Specifies the scope: Machine or User. Defaults to Machine.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-EnvironmentVariable.ps1 -Name "MY_VAR" -Value "HelloWorld" -Scope User

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$Value = "",

    [ValidateSet('Machine', 'User')]
    [string]$Scope = 'Machine',

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($VarName, $VarValue, $VarScope)
            [System.Environment]::SetEnvironmentVariable($VarName, $VarValue, $VarScope)
            
            $val = [System.Environment]::GetEnvironmentVariable($VarName, $VarScope)
            [PSCustomObject]@{
                Name   = $VarName
                Value  = $val
                Scope  = $VarScope
                Status = if ($val) { "Configured" } else { "Removed" }
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Name, $Value, $Scope)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -VarName $Name -VarValue $Value -VarScope $Scope
        }

        $result | Add-Member -MemberType NoteProperty -Name ComputerName -Value $ComputerName -PassThru
        Write-Output $result
    }
    catch {
        throw
    }
}
