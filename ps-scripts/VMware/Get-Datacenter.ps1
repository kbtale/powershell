#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        VMware: Retrieves datacenters available on a vCenter Server system

    .DESCRIPTION
        Connects to a vCenter Server and retrieves datacenters by name; if no name is provided, all datacenters are retrieved.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER Datacenter
        Name of the datacenter to retrieve; if empty, all datacenters are retrieved

    .EXAMPLE
        Get-Datacenter -VIServer "vcenter.contoso.com" -VICredential $cred

    .CATEGORY VMware
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$Datacenter
)

Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        if ([System.String]::IsNullOrWhiteSpace($Datacenter)) {
            $result = Get-Datacenter -Server $vmServer -ErrorAction Stop | Select-Object *
        }
        else {
            $result = Get-Datacenter -Server $vmServer -Name $Datacenter -ErrorAction Stop | Select-Object *
        }

        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
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
