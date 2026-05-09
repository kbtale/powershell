#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Exposes the ESXCLI functionality
.DESCRIPTION
    Gets an ESXCLI object for a specified host to run ESXCLI commands.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Name of the host to expose ESXCLI; retrieves from all hosts if empty
.PARAMETER V2
    Returns ESXCLI object version 2 (V2) instead of version 1
.EXAMPLE
    PS> ./Get-EsxCli.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esx01.contoso.com"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$HostName,
    [switch]$V2
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ([System.String]::IsNullOrWhiteSpace($HostName)) {
            $result = Get-EsxCli -Server $vmServer -V2:$V2 -ErrorAction Stop | Select-Object *
        }
        else {
            $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
            $result = Get-EsxCli -Server $vmServer -V2:$V2 -VMHost $vmHost -ErrorAction Stop | Select-Object *
        }
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}