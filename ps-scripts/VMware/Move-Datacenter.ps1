#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        VMware: Moves a vCenter Server datacenter from one location to another

    .DESCRIPTION
        Connects to a vCenter Server and moves a specified datacenter to a destination folder.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER Datacenter
        Name of the datacenter to move

    .PARAMETER DestinationFolder
        Name of the destination folder

    .EXAMPLE
        Move-Datacenter -VIServer "vcenter.contoso.com" -VICredential $cred -Datacenter "OldDC" -DestinationFolder "NewFolder"

    .CATEGORY VMware
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Datacenter,
    [Parameter(Mandatory = $true)]
    [string]$DestinationFolder
)

Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

        $dCenter = Get-Datacenter -Server $vmServer -Name $Datacenter -ErrorAction Stop
        $folder = Get-Folder -Server $vmServer -Name $DestinationFolder -Type Datacenter -ErrorAction Stop
        $null = Move-Datacenter -Server $vmServer -Datacenter $dCenter -Destination $folder -Confirm:$false -ErrorAction Stop
        $result = Get-Datacenter -Server $vmServer -Name $Datacenter -ErrorAction Stop | Select-Object *
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

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
