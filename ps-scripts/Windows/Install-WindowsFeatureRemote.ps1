#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Installs or enables a Windows Feature

.DESCRIPTION
    Installs a specified Windows Feature (on Servers) or enables an Optional Feature (on Clients). This script automatically detects the OS type and handles the appropriate command execution on local or remote systems.

.PARAMETER Name
    Specifies the internal name of the feature to install/enable.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER IncludeManagementTools
    (Server only) If set, installs all management tools related to the feature.

.PARAMETER Reboot
    If set, reboots the computer if required by the installation.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Install-WindowsFeatureRemote.ps1 -Name "RSAT-AD-PowerShell" -IncludeManagementTools

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$Name,

    [string]$ComputerName = $env:COMPUTERNAME,

    [switch]$IncludeManagementTools,

    [switch]$Reboot,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($FeatureName, $Tools, $Restart)
            
            if (Get-Command -Name Install-WindowsFeature -ErrorAction SilentlyContinue) {
                $params = @{
                    'Name'                   = $FeatureName
                    'IncludeManagementTools' = $Tools
                    'Restart'                = $Restart
                    'ErrorAction'            = 'Stop'
                }
                $res = Install-WindowsFeature @params
            }
            else {
                $params = @{
                    'Online'      = $true
                    'FeatureName' = $FeatureName
                    'NoRestart'   = (-not $Restart)
                    'ErrorAction' = 'Stop'
                }
                $res = Enable-WindowsOptionalFeature @params
            }
            $res
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Name, $IncludeManagementTools, $Reboot)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -FeatureName $Name -Tools $IncludeManagementTools -Restart $Reboot
        }

        $output = [PSCustomObject]@{
            Feature      = $Name
            Success      = $result.Success
            ExitCode     = $result.ExitCode
            RebootNeeded = $result.RestartNeeded
            ComputerName = $ComputerName
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
