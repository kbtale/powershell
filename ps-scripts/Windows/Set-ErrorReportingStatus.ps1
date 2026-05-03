#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Configures Windows Error Reporting (WER) status

.DESCRIPTION
    Enables or disables Windows Error Reporting on a local or remote computer.

.PARAMETER Enabled
    Specifies whether to enable or disable Windows Error Reporting.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-ErrorReportingStatus.ps1 -Enabled $false

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [bool]$Enabled,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($IsEnabled)
            Import-Module WindowsErrorReporting -ErrorAction SilentlyContinue
            if ($IsEnabled) {
                Enable-WindowsErrorReporting -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 0 -Force -ErrorAction SilentlyContinue
            }
            else {
                Disable-WindowsErrorReporting -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 1 -Force -ErrorAction SilentlyContinue
            }
            Get-WindowsErrorReporting -ErrorAction SilentlyContinue
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = $Enabled
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $status = Invoke-Command @invokeParams
        }
        else {
            $status = &$scriptBlock -IsEnabled $Enabled
        }

        $result = [PSCustomObject]@{
            WEREnabled   = $Enabled
            ComputerName = $ComputerName
            Action       = "WERConfigured"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
