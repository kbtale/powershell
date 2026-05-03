#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Configures User Account Control (UAC) levels

.DESCRIPTION
    Adjusts the User Account Control (UAC) security settings via registry. This includes setting the notification level and enabling/disabling the secure desktop prompt. Note: Changes to 'EnableLUA' require a system reboot to take effect.

.PARAMETER Level
    Specifies the UAC notification level:
    - AlwaysNotify (1): Notify always (most secure).
    - Default (2): Default (Notify when apps make changes).
    - NotifyOnly (3): Notify only when apps try to make changes (No secure desktop).
    - NeverNotify (4): Never notify (least secure).

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Reboot
    If set, reboots the computer after applying the changes.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-UacConfig.ps1 -Level NeverNotify -Reboot

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true)]
    [ValidateSet('AlwaysNotify', 'Default', 'NotifyOnly', 'NeverNotify')]
    [string]$Level,

    [string]$ComputerName = $env:COMPUTERNAME,

    [switch]$Reboot,

    [pscredential]$Credential
)

Process
{
    try
    {
        $uacMap = @{
            'AlwaysNotify' = @{ 'LUA' = 1; 'Sec' = 1; 'Prompt' = 2 }
            'Default'      = @{ 'LUA' = 1; 'Sec' = 1; 'Prompt' = 5 }
            'NotifyOnly'   = @{ 'LUA' = 1; 'Sec' = 0; 'Prompt' = 5 }
            'NeverNotify'  = @{ 'LUA' = 0; 'Sec' = 0; 'Prompt' = 0 }
        }

        $settings = $uacMap[$Level]
        
        $scriptBlock = {
            Param($S)
            $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            Set-ItemProperty -Path $key -Name "ConsentPromptBehaviorAdmin" -Value $S.Prompt -Force
            Set-ItemProperty -Path $key -Name "ConsentPromptBehaviorUser" -Value $S.Prompt -Force
            Set-ItemProperty -Path $key -Name "PromptOnSecureDesktop" -Value $S.Sec -Force
            Set-ItemProperty -Path $key -Name "EnableLUA" -Value $S.LUA -Force
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = $settings
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential)
            {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
            
            if ($Reboot)
            {
                Restart-Computer -ComputerName $ComputerName -Force -Confirm:$false
            }
        }
        else
        {
            &$scriptBlock -S $settings
            if ($Reboot)
            {
                Restart-Computer -Force -Confirm:$false
            }
        }

        $result = [PSCustomObject]@{
            Level        = $Level
            ComputerName = $ComputerName
            Action       = "Configured"
            Reboot       = if ($Reboot) { "Initiated" } else { "Required" }
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch
    {
        throw
    }
}
