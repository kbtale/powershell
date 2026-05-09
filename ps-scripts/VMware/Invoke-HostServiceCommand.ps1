#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Invokes a command for the specified host services (Start, Stop, Restart)
.DESCRIPTION
    Executes a service command on host services filtered by key or label.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host for which to invoke the command
.PARAMETER ServiceKey
    Key of the service to invoke the command on
.PARAMETER ServiceLabel
    Label of the service to invoke the command on
.PARAMETER Command
    Command to execute: Start, Stop, or Restart
.EXAMPLE
    PS> ./Invoke-HostServiceCommand.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -Command "Restart"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [string]$ServiceKey,
    [string]$ServiceLabel,
    [ValidateSet("Start", "Stop", "Restart")]
    [string]$Command = "Restart"
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $services = Get-VMHostService -Server $vmServer -VMHost $HostName -ErrorAction Stop
        $output = @()
        if (-not [System.String]::IsNullOrWhiteSpace($ServiceKey)) {
            $output += $services | Where-Object { $_.Key -like $ServiceKey }
        }
        if (-not [System.String]::IsNullOrWhiteSpace($ServiceLabel)) {
            $output += $services | Where-Object { $_.Label -like $ServiceLabel }
        }
        if ($output.Count -le 0) { $output = $services }
        switch ($Command) {
            "Start"   { $output = $output | Start-VMHostService -Confirm:$false -ErrorAction Stop | Select-Object * }
            "Stop"    { $output = $output | Stop-VMHostService -Confirm:$false -ErrorAction Stop | Select-Object * }
            "Restart" { $output = $output | Restart-VMHostService -Confirm:$false -ErrorAction Stop | Select-Object * }
        }
        foreach ($item in $output) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
