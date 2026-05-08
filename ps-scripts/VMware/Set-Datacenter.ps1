#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        VMware: Modifies the properties of the specified datacenter

    .DESCRIPTION
        Connects to a vCenter Server and renames a datacenter.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER Datacenter
        Name of the datacenter to modify

    .PARAMETER NewName
        New name for the datacenter

    .EXAMPLE
        Set-Datacenter -VIServer "vcenter.contoso.com" -VICredential $cred -Datacenter "OldName" -NewName "NewDC"

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
    [string]$NewName
)

Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

        $dCenter = Get-Datacenter -Server $vmServer -Name $Datacenter -ErrorAction Stop

        if ($PSBoundParameters.ContainsKey('NewName')) {
            $dCenter = Set-Datacenter -Server $vmServer -Datacenter $dCenter -Name $NewName -Confirm:$false -ErrorAction Stop | Select-Object *
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $dCenter | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
        Write-Output $dCenter
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
