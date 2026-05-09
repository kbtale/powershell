#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves entries from vSphere logs
.DESCRIPTION
    Retrieves log entries from a specified host, optionally as a diagnostic bundle.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Name of the host to retrieve logs from
.PARAMETER LogFileKey
    Key identifier of the log file to retrieve; auto-detected if empty
.PARAMETER StartLineNumber
    Start line number for reading from the logs
.PARAMETER LineNumbers
    Number of lines to retrieve from the logs
.PARAMETER Bundle
    Retrieve a diagnostic bundle of logs
.PARAMETER DestinationPath
    Local file path where to save the log bundle
.EXAMPLE
    PS> ./Get-HostLogs.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
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
    [string]$LogFileKey,
    [int32]$StartLineNumber = 1,
    [int32]$LineNumbers = 20,
    [switch]$Bundle,
    [string]$DestinationPath
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        if ($Bundle) {
            $result = Get-Log -Server $vmServer -VMHost $vmHost -Bundle -DestinationPath $DestinationPath -ErrorAction Stop
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
                Write-Output $item
            }
        }
        else {
            if ([System.String]::IsNullOrWhiteSpace($LogFileKey)) {
                $LogFileKey = Get-LogType -Server $vmServer -VMHost $vmHost -ErrorAction Stop | Select-Object -First 1 -ExpandProperty Key
            }
            $result = Get-Log -Server $vmServer -VMHost $vmHost -Key $LogFileKey -StartLineNum $StartLineNumber -NumLines $LineNumbers -ErrorAction Stop | Select-Object -ExpandProperty Entries
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
                Write-Output $item
            }
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
