#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Downloads new patches into the Update Manager patch repository
.DESCRIPTION
    Downloads new patches from the enabled patch download sources.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER RunAsync
    Returns immediately without waiting for task completion
.EXAMPLE
    PS> ./Sync-Patch.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -RunAsync
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [switch]$RunAsync
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($RunAsync) { $cmdArgs.Add('RunAsync', $null) }
        $result = Sync-Patch @cmdArgs | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}