#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves status of Windows Features or Optional Features

.DESCRIPTION
    Lists available and installed Windows Features (on Servers) or Optional Features (on Clients). This script automatically detects the operating system type and uses the appropriate cmdlet to provide a status report.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Name
    Specifies the name of a specific feature to query. Supports wildcards.

.PARAMETER InstalledOnly
    If set, only returns features that are currently installed/enabled.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-WindowsFeatureInfo.ps1 -InstalledOnly

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$Name = "*",

    [switch]$InstalledOnly,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($FeatureName, $OnlyInstalled)
            
            $results = @()
            # Try Server Features first
            if (Get-Command -Name Get-WindowsFeature -ErrorAction SilentlyContinue) {
                $results = Get-WindowsFeature -Name $FeatureName | Select-Object Name, DisplayName, Installed, @{N = 'Status'; E = { $_.InstallState } }
            }
            # Fallback to Optional Features (Client OS)
            else {
                $results = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName | Select-Object FeatureName, DisplayName, @{N = 'Installed'; E = { $_.State -eq 'Enabled' } }, @{N = 'Status'; E = { $_.State } } | Rename-Item -NewName @{FeatureName = 'Name' } -ErrorAction SilentlyContinue
                # Note: Manual rename if needed
                $results = $results | ForEach-Object {
                    [PSCustomObject]@{
                        Name        = $_.FeatureName
                        DisplayName = $_.DisplayName
                        Installed   = $_.Installed
                        Status      = $_.Status
                    }
                }
            }

            if ($OnlyInstalled) {
                $results = $results | Where-Object { $_.Installed -eq $true }
            }

            $results
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Name, $InstalledOnly)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -FeatureName $Name -OnlyInstalled $InstalledOnly
        }

        $finalResults = foreach ($r in $result) {
            [PSCustomObject]@{
                Name         = $r.Name
                DisplayName  = $r.DisplayName
                Installed    = $r.Installed
                Status       = $r.Status
                ComputerName = $ComputerName
            }
        }

        Write-Output ($finalResults | Sort-Object Name)
    }
    catch {
        throw
    }
}
