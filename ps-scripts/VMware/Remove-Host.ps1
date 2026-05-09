#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes the specified host from the inventory
.DESCRIPTION
    Removes a host by ID or name from the vCenter Server system.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the host to remove
.PARAMETER Name
    Name of the host to remove
.EXAMPLE
    PS> ./Remove-Host.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "esxi01"
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
    [string]$ID,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$Name
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $vmHost = Get-VMHost -Server $vmServer -ID $ID -ErrorAction Stop
        }
        else {
            $vmHost = Get-VMHost -Server $vmServer -Name $Name -ErrorAction Stop
        }
        $hostName = $vmHost.Name
        $null = Remove-VMHost -VMHost $vmHost -Server $vmServer -Confirm:$false -ErrorAction Stop
        $output = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            Message   = "Host $hostName successfully removed"
        }
        Write-Output $output
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
