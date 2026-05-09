#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Retrieves inventory items from a vCenter Server system
.DESCRIPTION
    Retrieves inventory items by name with optional recursive behavior.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name of the inventory object to retrieve; retrieves all if empty
.PARAMETER NoRecursion
    Disable recursive behavior
.EXAMPLE
    PS> ./Get-Inventory.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$Name = '*',
    [switch]$NoRecursion
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $result = Get-Inventory -Server $vmServer -NoRecursion:$NoRecursion -Name $Name -ErrorAction Stop
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}