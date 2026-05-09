#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Modifies the VMware PowerCLI configuration
.DESCRIPTION
    Modifies PowerCLI settings including proxy, certificate handling, and CEIP participation.
.PARAMETER Scope
    Scope: Session, User, or AllUsers
.PARAMETER InvalidCertificateAction
    Action on certificate errors: Fail, Ignore, Prompt, Unset, Warn
.PARAMETER DisplayDeprecationWarnings
    Show warnings about deprecated elements
.PARAMETER DefaultVIServerMode
    Server connection mode: Multiple or Single
.PARAMETER WebOperationTimeoutSeconds
    Timeout for Web operations
.PARAMETER ProxyPolicy
    System proxy usage: UseSystemProxy or NoProxy
.PARAMETER CEIPDataTransferProxyPolicy
    Proxy policy for CEIP data transfer
.PARAMETER ParticipateInCEIP
    Send anonymous usage information to VMware
.EXAMPLE
    PS> ./Set-PowerCLIConfiguration.ps1 -Scope "User" -InvalidCertificateAction "Ignore"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Session", "User", "AllUsers")]
    [string]$Scope = "User",
    [ValidateSet("Fail", "Ignore", "Prompt", "Unset", "Warn")]
    [string]$InvalidCertificateAction,
    [ValidateSet("Multiple", "Single")]
    [string]$DefaultVIServerMode,
    [bool]$DisplayDeprecationWarnings,
    [int32]$WebOperationTimeoutSeconds,
    [ValidateSet("UseSystemProxy", "NoProxy")]
    [string]$ProxyPolicy,
    [bool]$ParticipateInCEIP,
    [ValidateSet("UseSystemProxy", "NoProxy")]
    [string]$CEIPDataTransferProxyPolicy
)
Process {
    try {
        $setArgs = @{ ErrorAction = 'Stop'; Scope = $Scope; Confirm = $false }
        if ($WebOperationTimeoutSeconds -gt 0) { $null = Set-PowerCLIConfiguration @setArgs -WebOperationTimeoutSeconds $WebOperationTimeoutSeconds }
        if (-not [System.String]::IsNullOrWhiteSpace($InvalidCertificateAction)) { $null = Set-PowerCLIConfiguration @setArgs -InvalidCertificateAction $InvalidCertificateAction }
        if (-not [System.String]::IsNullOrWhiteSpace($DefaultVIServerMode)) { $null = Set-PowerCLIConfiguration @setArgs -DefaultVIServerMode $DefaultVIServerMode }
        if (-not [System.String]::IsNullOrWhiteSpace($ProxyPolicy)) { $null = Set-PowerCLIConfiguration @setArgs -ProxyPolicy $ProxyPolicy }
        if ($PSBoundParameters.ContainsKey('DisplayDeprecationWarnings')) { $null = Set-PowerCLIConfiguration @setArgs -DisplayDeprecationWarnings $DisplayDeprecationWarnings }
        if ($PSBoundParameters.ContainsKey('ParticipateInCEIP')) { $null = Set-PowerCLIConfiguration @setArgs -ParticipateInCEIP $ParticipateInCEIP }
        if (-not [System.String]::IsNullOrWhiteSpace($CEIPDataTransferProxyPolicy)) { $null = Set-PowerCLIConfiguration @setArgs -CEIPDataTransferProxyPolicy $CEIPDataTransferProxyPolicy }
        $result = Get-PowerCLIConfiguration -Scope $Scope -ErrorAction Stop | Format-List
        Write-Output $result
    }
    catch { throw }
}