#Requires -Version 5.1

<#
.SYNOPSIS
    Security: Audits active Windows Defender Firewall rules for high-risk ingress connections
.DESCRIPTION
    Scans enabled inbound firewall rules, flagging potential security risks such as administrative ports (RDP, SMB, SSH, WinRM, FTP, Telnet) exposed to any remote IP.
.PARAMETER OnlyActive
    Only audit firewall rules that are currently enabled. Defaults to true.
.EXAMPLE
    PS> ./Audit-FirewallRules.ps1 -OnlyActive
.CATEGORY Security
#>

[CmdletBinding()]
Param(
    [switch]$OnlyActive = $true
)

Process {
    try {
        Write-Verbose "Querying Windows Defender Firewall inbound rules..."
        
        $rules = Get-NetFirewallRule -Direction Inbound -ErrorAction Stop
        if ($OnlyActive) {
            $rules = $rules | Where-Object { $_.Enabled -eq 'True' }
        }

        # Define high-risk ports and their descriptions
        $highRiskPorts = @{
            "3389" = "Remote Desktop (RDP)"
            "445"  = "Server Message Block (SMB)"
            "139"  = "NetBIOS Session Service"
            "22"   = "Secure Shell (SSH)"
            "5985" = "Windows Remote Management (WinRM HTTP)"
            "5986" = "Windows Remote Management (WinRM HTTPS)"
            "23"   = "Telnet (Insecure Console)"
            "21"   = "File Transfer Protocol (FTP)"
        }

        $results = @()

        foreach ($rule in $rules) {
            # Get port filters associated with this rule
            $portFilter = $rule | Get-NetFirewallPortFilter -ErrorAction SilentlyContinue
            # Get address filters associated with this rule
            $addressFilter = $rule | Get-NetFirewallAddressFilter -ErrorAction SilentlyContinue

            if (-not $portFilter -or -not $addressFilter) { continue }

            $localPorts = $portFilter.LocalPort
            $remoteAddresses = $addressFilter.RemoteAddress

            # We care about rules targeting high-risk ports or ANY port exposed to wildcard address 'Any' or '*'
            foreach ($port in $localPorts) {
                # Map wildcard port ranges or standard ports
                $isHighRiskPort = $highRiskPorts.ContainsKey($port)
                $isWildcardAddress = ($remoteAddresses -contains 'Any' -or $remoteAddresses -contains '*')

                if ($isHighRiskPort -and $isWildcardAddress) {
                    $results += [PSCustomObject]@{
                        RuleName        = $rule.DisplayName
                        LocalPort       = $port
                        ServiceType     = $highRiskPorts[$port]
                        Protocol        = $portFilter.Protocol
                        RemoteAddress   = ($remoteAddresses -join ', ')
                        Action          = $rule.Action
                        Profile         = ($rule.Profile -join ', ')
                        RiskLevel       = "CRITICAL: Admin Port Exposed to Wildcard!"
                    }
                }
                elseif ($isWildcardAddress -and $rule.Action -eq 'Allow' -and $port -eq 'Any') {
                    $results += [PSCustomObject]@{
                        RuleName        = $rule.DisplayName
                        LocalPort       = "Any"
                        ServiceType     = "All Services (Wildcard)"
                        Protocol        = $portFilter.Protocol
                        RemoteAddress   = ($remoteAddresses -join ', ')
                        Action          = $rule.Action
                        Profile         = ($rule.Profile -join ', ')
                        RiskLevel       = "HIGH: Full Port Exposure to Wildcard Address"
                    }
                }
            }
        }

        if ($results.Count -eq 0) {
            Write-Host "No high-risk firewall rules found. Windows Firewall ingress configuration is compliant!" -ForegroundColor Green
        } else {
            Write-Warning "Audited firewall rules flagged potential vulnerabilities. See summary below:"
            Write-Output ($results | Sort-Object RiskLevel -Descending)
        }
    }
    catch {
        Write-Error $_
        throw
    }
}
