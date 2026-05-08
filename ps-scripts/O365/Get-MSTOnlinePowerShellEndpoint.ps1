#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get Online PowerShell endpoint
.DESCRIPTION
    Returns the Online PowerShell endpoint URL for a target domain.
.PARAMETER TargetDomain
    The target domain to discover the endpoint for
.PARAMETER OverrideDesiredLink
    Override the desired link value
.PARAMETER OverrideDiscoveryUri
    Override the discovery URI value
.EXAMPLE
    PS> ./Get-MSTOnlinePowerShellEndpoint.ps1 -TargetDomain "contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$TargetDomain,
    [string]$OverrideDesiredLink,
    [string]$OverrideDiscoveryUri
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'TargetDomain' = $TargetDomain}

        if (-not [System.String]::IsNullOrWhiteSpace($OverrideDesiredLink)) {
            $cmdArgs.Add('OverrideDesiredLink', $OverrideDesiredLink)
        }
        if (-not [System.String]::IsNullOrWhiteSpace($OverrideDiscoveryUri)) {
            $cmdArgs.Add('OverrideDiscoveryUri', $OverrideDiscoveryUri)
        }

        $result = Get-CsOnlinePowerShellEndpoint @cmdArgs

        if ($null -eq $result) {
            Write-Output "No endpoint found"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
