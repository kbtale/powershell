#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Configures automatic update settings (AUOptions)

.DESCRIPTION
    Manages how Windows handles automatic updates via registry policies. This script allows for enabling/disabling auto-updates and setting specific behaviors like 'Notify only' or 'Auto install'.

.PARAMETER Mode
    Specifies the update behavior:
    - Default (0): System default behavior.
    - Disabled (1): Never check for updates.
    - NotifyOnly (2): Notify for download and install.
    - AutoDownload (3): Auto download, notify for install.
    - AutoInstall (4): Auto download and schedule install.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-AutoUpdateConfig.ps1 -Mode NotifyOnly

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Default', 'Disabled', 'NotifyOnly', 'AutoDownload', 'AutoInstall')]
    [string]$Mode,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process
{
    try
    {
        $optionMap = @{
            'Default'      = 0
            'Disabled'     = 1
            'NotifyOnly'   = 2
            'AutoDownload' = 3
            'AutoInstall'  = 4
        }

        $val = $optionMap[$Mode]
        
        $scriptBlock = {
            Param($OptionValue)
            $basePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
            $auPath = "$basePath\AU"

            if ($OptionValue -eq 0)
            {
                if (Test-Path $basePath)
                {
                    Remove-Item -Path $basePath -Recurse -Force
                }
            }
            else
            {
                if (-not (Test-Path $auPath))
                {
                    New-Item -Path $auPath -Force | Out-Null
                }

                if ($OptionValue -eq 1)
                {
                    Set-ItemProperty -Path $auPath -Name "NoAutoUpdate" -Value 1 -Force
                }
                else
                {
                    Set-ItemProperty -Path $auPath -Name "NoAutoUpdate" -Value 0 -Force
                    Set-ItemProperty -Path $auPath -Name "AUOptions" -Value $OptionValue -Force
                    # Default schedule: Daily at 3 AM
                    Set-ItemProperty -Path $auPath -Name "ScheduledInstallDay" -Value 0 -Force
                    Set-ItemProperty -Path $auPath -Name "ScheduledInstallTime" -Value 3 -Force
                }
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = $val
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential)
            {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
        }
        else
        {
            &$scriptBlock -OptionValue $val
        }

        $result = [PSCustomObject]@{
            Mode         = $Mode
            Value        = $val
            ComputerName = $ComputerName
            Action       = "Configured"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch
    {
        throw
    }
}
