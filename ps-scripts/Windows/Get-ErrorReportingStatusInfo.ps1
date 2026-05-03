#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves the status of Windows Error Reporting (WER)

.DESCRIPTION
    Checks whether Windows Error Reporting is enabled or disabled on a local or remote computer.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-ErrorReportingStatusInfo.ps1 -ComputerName "SRV01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Import-Module WindowsErrorReporting -ErrorAction SilentlyContinue
            $status = Get-WindowsErrorReporting -ErrorAction SilentlyContinue
            if ($null -eq $status) {
                # Fallback to registry check if module is not available or fails
                $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting"
                $val = Get-ItemProperty -Path $regPath -Name "Disabled" -ErrorAction SilentlyContinue
                if ($null -ne $val) {
                    $status = if ($val.Disabled -eq 1) { $false } else { $true }
                }
            }
            $status
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $status = Invoke-Command @invokeParams
        }
        else {
            $status = &$scriptBlock
        }

        $result = [PSCustomObject]@{
            WEREnabled   = if ($null -eq $status) { "Unknown" } else { $status }
            ComputerName = $ComputerName
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
