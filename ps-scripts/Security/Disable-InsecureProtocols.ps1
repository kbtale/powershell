#Requires -Version 5.1

<#
.SYNOPSIS
    Security: Hardens system SSL/TLS configuration by disabling insecure Schannel protocols
.DESCRIPTION
    Safely modifies the local registry Schannel configuration to disable legacy, vulnerable protocols (SSL 2.0, SSL 3.0, TLS 1.0, TLS 1.1) and enforces high-security modern protocols (TLS 1.2 and TLS 1.3).
.EXAMPLE
    PS> ./Disable-InsecureProtocols.ps1 -WhatIf
.CATEGORY Security
#>

[CmdletBinding(SupportsShouldProcess = $true)]
Param()

Process {
    try {
        $schannelPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
        
        $protocolsToDisable = @('SSL 2.0', 'SSL 3.0', 'TLS 1.0', 'TLS 1.1')
        $protocolsToEnable  = @('TLS 1.2', 'TLS 1.3')

        $results = @()

        # Helper function to configure a registry key
        function Set-SchannelRegistryKey {
            param(
                [string]$ProtocolName,
                [string]$SubKey, # Client or Server
                [long]$Enabled,
                [int]$DisabledByDefault
            )

            $fullPath = Join-Path $schannelPath "$ProtocolName\$SubKey"
            $status = "No Change"

            if ($PSCmdlet.ShouldProcess($fullPath, "Configure Schannel Protocol (Enabled=$Enabled, DisabledByDefault=$DisabledByDefault)")) {
                try {
                    # Create parent path recursively if needed
                    $parentPath = Join-Path $schannelPath $ProtocolName
                    if (-not (Test-Path -Path $parentPath)) {
                        New-Item -Path $schannelPath -Name $ProtocolName -Force | Out-Null
                    }
                    if (-not (Test-Path -Path $fullPath)) {
                        New-Item -Path $parentPath -Name $SubKey -Force | Out-Null
                    }

                    # Set registry properties
                    Set-ItemProperty -Path $fullPath -Name "Enabled" -Value $Enabled -Type DWORD -Force | Out-Null
                    Set-ItemProperty -Path $fullPath -Name "DisabledByDefault" -Value $DisabledByDefault -Type DWORD -Force | Out-Null
                    $status = "Configured Successfully"
                }
                catch {
                    $status = "Failed: $_"
                    Write-Error "Failed to set registry keys on $fullPath: $_"
                }
            } else {
                $status = "WhatIf Preview (No Action Taken)"
            }

            return [PSCustomObject]@{
                Protocol          = $ProtocolName
                Component         = $SubKey
                TargetEnabled     = ($Enabled -ne 0)
                TargetDisabledDef = ($DisabledByDefault -eq 1)
                Status            = $status
            }
        }

        # Process Disable Rules
        foreach ($proto in $protocolsToDisable) {
            $results += Set-SchannelRegistryKey -ProtocolName $proto -SubKey "Client" -Enabled 0 -DisabledByDefault 1
            $results += Set-SchannelRegistryKey -ProtocolName $proto -SubKey "Server" -Enabled 0 -DisabledByDefault 1
        }

        # Process Enable Rules
        foreach ($proto in $protocolsToEnable) {
            # On Windows, enabling TLS 1.2/1.3 can be represented by DWORD 0xffffffff (-1/4294967295) or 1.
            $results += Set-SchannelRegistryKey -ProtocolName $proto -SubKey "Client" -Enabled 4294967295 -DisabledByDefault 0
            $results += Set-SchannelRegistryKey -ProtocolName $proto -SubKey "Server" -Enabled 4294967295 -DisabledByDefault 0
        }

        Write-Host "Schannel protocol hardening configuration summary:" -ForegroundColor Green
        Write-Output $results
        Write-Host "IMPORTANT: A system restart is required for Schannel SSL/TLS changes to take effect." -ForegroundColor Yellow
    }
    catch {
        Write-Error $_
        throw
    }
}
