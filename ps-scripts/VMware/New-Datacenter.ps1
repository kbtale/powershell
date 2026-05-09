#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        VMware: Creates a new datacenter

    .DESCRIPTION
        Connects to a vCenter Server and creates a new datacenter in the specified folder.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER CenterName
        Name for the new datacenter

    .PARAMETER FolderName
        Location folder where the new datacenter will be created

    .EXAMPLE
        New-Datacenter -VIServer "vcenter.contoso.com" -VICredential $cred -CenterName "DC-East" -FolderName "Datacenters"

    .CATEGORY VMware
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$CenterName,
    [string]$FolderName
)

Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $folder = Get-Folder -Server $vmServer -Name $FolderName -ErrorAction Stop
        $null = New-Datacenter -Server $vmServer -Name $CenterName -Location $folder -Confirm:$false -ErrorAction Stop
        $result = Get-Datacenter -Server $vmServer -Name $CenterName -ErrorAction Stop | Select-Object *
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
