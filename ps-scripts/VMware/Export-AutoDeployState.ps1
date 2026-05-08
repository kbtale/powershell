#Requires -Version 5.1
#Requires -Modules VMware.DeployAutomation

<#
    .SYNOPSIS
        VMware: Backs up the state of the Auto Deploy service

    .DESCRIPTION
        Connects to a vSphere server and exports the Auto Deploy service state to a specified directory.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER ExportDir
        Export directory where the file will be written

    .EXAMPLE
        Export-AutoDeployState -VIServer "vcenter.contoso.com" -VICredential $cred -ExportDir "C:\Backup"

    .CATEGORY VMware
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$ExportDir
)

Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $result = Export-AutoDeployState -Server $vmServer -ExportDir $ExportDir -ErrorAction Stop
        $output = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            Result    = $result
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
