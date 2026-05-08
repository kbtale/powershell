#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        VMware: Removes the specified datacenter

    .DESCRIPTION
        Connects to a vCenter Server and removes a datacenter by ID or name.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER DatacenterID
        ID of the datacenter to remove

    .PARAMETER DatacenterName
        Name of the datacenter to remove

    .EXAMPLE
        Remove-Datacenter -VIServer "vcenter.contoso.com" -VICredential $cred -DatacenterName "OldDC"

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
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$DatacenterName,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$DatacenterID
)

Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $dCenter = Get-Datacenter -Server $vmServer -Id $DatacenterID -ErrorAction Stop
        }
        else {
            $dCenter = Get-Datacenter -Server $vmServer -Name $DatacenterName -ErrorAction Stop
        }
        $dcName = $dCenter.Name
        Remove-Datacenter -Datacenter $dCenter -Server $vmServer -Confirm:$false -ErrorAction Stop

        $output = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            Message   = "Datacenter $dcName removed"
        }
        Write-Output $output
    }
    catch {
        throw
    }
    finally {
        if ($null -ne $vmServer) {
            Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
}
