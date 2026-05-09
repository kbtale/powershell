#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Stops the specified task
.DESCRIPTION
    Stops a running task by its ID.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER TaskID
    ID of the task to stop
.EXAMPLE
    PS> ./Stop-Task.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -TaskID "task-123"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$TaskID
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $task = Get-Task -Server $vmServer -ID $TaskID -ErrorAction Stop
        $null = Stop-Task -Task $task -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Task $($task.Description) stopped" }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}