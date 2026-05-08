#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        VMware: Retrieves datastores available on a vCenter Server system

    .DESCRIPTION
        Connects to a vCenter Server and retrieves datastores by name; if no name is provided, all datastores are retrieved.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER Datastore
        Name of the datastore to retrieve

    .PARAMETER RefreshFirst
        Refreshes storage system information before retrieving

    .PARAMETER Properties
        List of properties to expand; use * for all properties

    .EXAMPLE
        Get-Datastore -VIServer "vcenter.contoso.com" -VICredential $cred

    .CATEGORY VMware
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$Datastore,
    [switch]$RefreshFirst,
    [ValidateSet('*', 'Name', 'State', 'CapacityGB', 'FreeSpaceGB', 'Datacenter')]
    [string[]]$Properties = @('Name', 'State', 'CapacityGB', 'FreeSpaceGB', 'Datacenter')
)

Process {
    $vmServer = $null
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        if ([System.String]::IsNullOrWhiteSpace($Datastore)) {
            $result = Get-Datastore -Server $vmServer -Refresh:$RefreshFirst -ErrorAction Stop | Select-Object $Properties
        }
        else {
            $result = Get-Datastore -Server $vmServer -Refresh:$RefreshFirst -Name $Datastore -ErrorAction Stop | Select-Object $Properties
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
