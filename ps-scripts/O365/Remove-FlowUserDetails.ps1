#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Removes flow user details
.DESCRIPTION
    Deletes user details associated with a flow.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER UserId
    The user ID to remove from the flow
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-FlowUserDetails.ps1 -PACredential $cred -UserId "user@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$UserId,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; UserId = $UserId }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-AdminFlowUserDetails @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Flow user details removed for '$UserId'" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
