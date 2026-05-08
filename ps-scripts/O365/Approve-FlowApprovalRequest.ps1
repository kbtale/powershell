#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Approves a flow approval request
.DESCRIPTION
    Approves a pending flow approval request with optional comments.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER ApprovalId
    ID of the approval to respond to
.PARAMETER ApprovalRequestId
    ID of the user's request for the approval
.PARAMETER EnvironmentName
    Environment containing the approval
.PARAMETER Comments
    Comments to attach to the response
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Approve-FlowApprovalRequest.ps1 -PACredential $cred -ApprovalId "abc" -ApprovalRequestId "xyz" -EnvironmentName "default" -Comments "Approved"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$ApprovalId,

    [Parameter(Mandatory = $true)]
    [string]$ApprovalRequestId,

    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,

    [Parameter(Mandatory = $true)]
    [string]$Comments,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $cmdArgs = @{
            ErrorAction         = 'Stop'
            EnvironmentName     = $EnvironmentName
            ApprovalRequestId   = $ApprovalRequestId
            ApprovalId          = $ApprovalId
            Comments            = $Comments
        }

        if ($PSBoundParameters.ContainsKey('ApiVersion')) {
            $cmdArgs.Add('ApiVersion', $ApiVersion)
        }

        $result = Approve-FlowApprovalRequest @cmdArgs -ErrorAction Stop | Select-Object *

        if ($null -ne $result) {
            $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
