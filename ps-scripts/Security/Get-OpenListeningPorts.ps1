#Requires -Version 5.1

<#
.SYNOPSIS
    Security: Identifies open listening network ports and maps them to active processes
.DESCRIPTION
    Scans the system for bound, listening TCP and UDP endpoints and resolves their active owning process IDs, process names, and file paths.
.PARAMETER Protocol
    The network protocol to query: 'TCP', 'UDP', or 'All'.
.EXAMPLE
    PS> ./Get-OpenListeningPorts.ps1 -Protocol TCP
.CATEGORY Security
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('TCP', 'UDP', 'All')]
    [string]$Protocol = 'All'
)

Process {
    try {
        $endpoints = @()

        # Query TCP listening connections
        if ($Protocol -eq 'TCP' -or $Protocol -eq 'All') {
            try {
                $tcpConns = Get-NetTCPConnection -State Listen -ErrorAction Stop
                foreach ($conn in $tcpConns) {
                    $endpoints += [PSCustomObject]@{
                        LocalAddress  = $conn.LocalAddress
                        LocalPort     = $conn.LocalPort
                        Protocol      = 'TCP'
                        OwningProcess = $conn.OwningProcess
                    }
                }
            }
            catch {
                Write-Warning "Failed to query TCP connections: $_"
            }
        }

        # Query UDP listening endpoints (UDP bound states are stateless)
        if ($Protocol -eq 'UDP' -or $Protocol -eq 'All') {
            try {
                $udpConns = Get-NetUDPEndpoint -ErrorAction Stop
                foreach ($conn in $udpConns) {
                    $endpoints += [PSCustomObject]@{
                        LocalAddress  = $conn.LocalAddress
                        LocalPort     = $conn.LocalPort
                        Protocol      = 'UDP'
                        OwningProcess = $conn.OwningProcess
                    }
                }
            }
            catch {
                Write-Warning "Failed to query UDP endpoints: $_"
            }
        }

        if ($endpoints.Count -eq 0) {
            Write-Output "No active listening ports found."
            return
        }

        $results = @()
        foreach ($ep in $endpoints) {
            $procName = 'Unknown'
            $procPath = 'Unknown / System Process'
            $cmdLine  = 'Unknown'

            if ($ep.OwningProcess -gt 0) {
                try {
                    $proc = Get-Process -Id $ep.OwningProcess -ErrorAction Stop
                    $procName = $proc.Name
                    
                    # Try to extract executable path (requires admin privileges for system processes)
                    if ($proc.Path) {
                        $procPath = $proc.Path
                    } else {
                        # Fallback to CIM query if path isn't exposed directly
                        $cimProc = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $($ep.OwningProcess)" -ErrorAction SilentlyContinue
                        if ($cimProc -and $cimProc.ExecutablePath) {
                            $procPath = $cimProc.ExecutablePath
                        }
                    }
                }
                catch {
                    # Process might have exited or access is denied
                    $procName = "PID $($ep.OwningProcess) [Inaccessible]"
                }
            }

            $results += [PSCustomObject]@{
                Protocol     = $ep.Protocol
                LocalAddress = $ep.LocalAddress
                LocalPort    = $ep.LocalPort
                ProcessId    = $ep.OwningProcess
                ProcessName  = $procName
                ProcessPath  = $procPath
            }
        }

        Write-Output ($results | Sort-Object LocalPort)
    }
    catch {
        Write-Error $_
        throw
    }
}
