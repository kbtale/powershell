#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Tests hosts for profile compliance
.DESCRIPTION
    Tests a host or profile for compliance with the associated host profile.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ProfileName
    Host profile against which to test compliance
.PARAMETER HostName
    Host to test for profile compliance
.PARAMETER UseCache
    Use cached vCenter Server information
.EXAMPLE
    PS> ./Test-HostProfileCompliance.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "Host")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Host")]
    [Parameter(Mandatory = $true, ParameterSetName = "Profile")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "Host")]
    [Parameter(Mandatory = $true, ParameterSetName = "Profile")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "Profile")]
    [string]$ProfileName,
    [Parameter(Mandatory = $true, ParameterSetName = "Host")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Host")]
    [Parameter(ParameterSetName = "Profile")]
    [switch]$UseCache
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "Profile") {
            $profile = Get-VMHostProfile -Server $vmServer -Name $ProfileName -ErrorAction Stop
            $result = Test-VMHostProfileCompliance -Server $vmServer -Profile $profile -UseCache:$UseCache -ErrorAction Stop | Select-Object *
        }
        else {
            $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
            $result = Test-VMHostProfileCompliance -Server $vmServer -VMHost $vmHost -UseCache:$UseCache -ErrorAction Stop | Select-Object *
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
