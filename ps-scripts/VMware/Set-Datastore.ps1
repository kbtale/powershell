#Requires -Version 5.1

<#
.SYNOPSIS
    VMware: Updates datastore properties
.DESCRIPTION
    Modifies properties of a datastore on a vCenter Server system.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    Credentials for authenticating with the server
.PARAMETER Datastore
    Name of the datastore to update
.PARAMETER Name
    New name for the datastore
.EXAMPLE
    PS> ./Set-Datastore.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Datastore "DS01" -Name "DS02"
.CATEGORY VMware
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Datastore,
    [string]$Name
)

Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Datastore = $Datastore; Confirm = $false }
        if (-not [System.String]::IsNullOrWhiteSpace($Name)) { $cmdArgs.Add('Name', $Name) }
        $result = Set-Datastore @cmdArgs | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
