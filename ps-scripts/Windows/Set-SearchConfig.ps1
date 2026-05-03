#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Configures Windows Search and Cortana settings

.DESCRIPTION
    Modifies system-wide search policies, including enabling/disabling Cortana, location usage for search, and web search integration. Supports local and remote systems.

.PARAMETER AllowCortana
    If set, enables Cortana search.

.PARAMETER AllowLocation
    If set, allows search and Cortana to use location data.

.PARAMETER DisableWebSearch
    If set, disables web results in Windows Search.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-SearchConfig.ps1 -AllowCortana $false -DisableWebSearch $true

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [bool]$AllowCortana,

    [bool]$AllowLocation,

    [bool]$DisableWebSearch,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Cortana, $Location, $Web, $BoundParams)
            $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            
            if ($BoundParams.ContainsKey('AllowCortana')) {
                $val = if ($Cortana) { 1 } else { 0 }
                Set-ItemProperty -Path $regPath -Name "AllowCortana" -Value $val -Force -ErrorAction Stop
            }
            if ($BoundParams.ContainsKey('AllowLocation')) {
                $val = if ($Location) { 1 } else { 0 }
                Set-ItemProperty -Path $regPath -Name "AllowSearchToUseLocation" -Value $val -Force -ErrorAction Stop
            }
            if ($BoundParams.ContainsKey('DisableWebSearch')) {
                $val = if ($Web) { 1 } else { 0 }
                Set-ItemProperty -Path $regPath -Name "DisableWebSearch" -Value $val -Force -ErrorAction Stop
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($AllowCortana, $AllowLocation, $DisableWebSearch, $PSBoundParameters)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
        }
        else {
            &$scriptBlock -Cortana $AllowCortana -Location $AllowLocation -Web $DisableWebSearch -BoundParams $PSBoundParameters
        }

        $result = [PSCustomObject]@{
            ComputerName = $ComputerName
            Action       = "SearchConfigured"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
