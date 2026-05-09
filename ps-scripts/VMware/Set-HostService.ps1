#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Configures a host service
.DESCRIPTION
    Sets the activation policy for host services filtered by key or label.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host for which to modify the available services
.PARAMETER ServiceKey
    Key of the service to modify
.PARAMETER ServiceLabel
    Label of the service to modify
.PARAMETER HostPolicy
    Activation policy for the host service
.EXAMPLE
    PS> ./Set-HostService.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -HostPolicy "Automatic"
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
    [ValidateSet("Automatic", "On", "Off")]
    [string]$HostPolicy = "Automatic"
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
        $output = $output | Set-VMHostService -Policy $HostPolicy -Confirm:$false -ErrorAction Stop | Select-Object *
        foreach ($item in $output) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
