#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves the start policy of the host
.DESCRIPTION
    Retrieves the host start policy by host ID or name.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostId
    ID of the host to retrieve
.PARAMETER HostName
    Name of the host to retrieve
.EXAMPLE
    PS> ./Get-HostStartPolicy.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "byName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$HostId,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$HostName
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $vmhost = Get-VMHost -Server $vmServer -Id $HostId -ErrorAction Stop
        }
        else {
            $vmhost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        }
        $result = Get-VMHostStartPolicy -Server $vmServer -VMHost $vmhost -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
