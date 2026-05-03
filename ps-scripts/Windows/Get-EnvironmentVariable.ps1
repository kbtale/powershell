#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves environment variables from specified scopes

.DESCRIPTION
    Lists environment variables on a local or remote computer. Supports filtering by name and querying specific scopes (Machine, User, Process).

.PARAMETER Name
    Specifies the name of the environment variable to retrieve. Supports wildcards.

.PARAMETER Scope
    Specifies the scope to query: Machine, User, or Process. Defaults to Process.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-EnvironmentVariable.ps1 -Scope Machine

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [string]$Name = "*",

    [ValidateSet('Machine', 'User', 'Process')]
    [string]$Scope = 'Process',

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($VarName, $VarScope)
            if ($VarScope -eq 'Process') {
                $vars = Get-ChildItem -Path Env: | Where-Object { $_.Name -like $VarName }
                $vars | ForEach-Object {
                    [PSCustomObject]@{
                        Name  = $_.Name
                        Value = $_.Value
                        Scope = 'Process'
                    }
                }
            }
            else {
                $results = [System.Environment]::GetEnvironmentVariables($VarScope)
                $results.Keys | Where-Object { $_ -like $VarName } | ForEach-Object {
                    [PSCustomObject]@{
                        Name  = $_
                        Value = $results[$_]
                        Scope = $VarScope
                    }
                }
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Name, $Scope)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -VarName $Name -VarScope $Scope
        }

        $results = foreach ($r in $result) {
            $r | Add-Member -MemberType NoteProperty -Name ComputerName -Value $ComputerName -PassThru
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
