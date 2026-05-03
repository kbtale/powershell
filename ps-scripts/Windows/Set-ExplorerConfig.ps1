#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Configures Windows Explorer settings

.DESCRIPTION
    Modifies Windows Explorer settings such as showing hidden files, hiding file extensions, and item check boxes. Supports local and remote systems.

.PARAMETER ShowHiddenFiles
    If set, shows hidden files and folders.

.PARAMETER HideFileExtensions
    If set, hides extensions for known file types.

.PARAMETER ShowCheckBoxes
    If set, enables item check boxes in Explorer.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-ExplorerConfig.ps1 -ShowHiddenFiles $true -HideFileExtensions $false

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [bool]$ShowHiddenFiles,

    [bool]$HideFileExtensions,

    [bool]$ShowCheckBoxes,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Hidden, $Extensions, $CheckBoxes, $BoundParams)
            
            $keys = @(
                "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            )
            
            foreach ($key in $keys) {
                if ($BoundParams.ContainsKey('ShowHiddenFiles')) {
                    $val = if ($Hidden) { 1 } else { 2 }
                    Set-ItemProperty -Path $key -Name "Hidden" -Value $val -Force -ErrorAction SilentlyContinue
                }
                if ($BoundParams.ContainsKey('HideFileExtensions')) {
                    $val = if ($Extensions) { 1 } else { 0 }
                    Set-ItemProperty -Path $key -Name "HideFileExt" -Value $val -Force -ErrorAction SilentlyContinue
                }
                if ($BoundParams.ContainsKey('ShowCheckBoxes')) {
                    $val = if ($CheckBoxes) { 1 } else { 0 }
                    Set-ItemProperty -Path $key -Name "AutoCheckSelect" -Value $val -Force -ErrorAction SilentlyContinue
                }
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($ShowHiddenFiles, $HideFileExtensions, $ShowCheckBoxes, $PSBoundParameters)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
        }
        else {
            &$scriptBlock -Hidden $ShowHiddenFiles -Extensions $HideFileExtensions -CheckBoxes $ShowCheckBoxes -BoundParams $PSBoundParameters
        }

        $result = [PSCustomObject]@{
            ComputerName = $ComputerName
            Action       = "ExplorerSettingsConfigured"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
