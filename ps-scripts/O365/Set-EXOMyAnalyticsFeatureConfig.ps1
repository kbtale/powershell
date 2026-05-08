#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Configures MyAnalytics features for a user
.DESCRIPTION
    Configures the availability and features of MyAnalytics for the specified user.
.PARAMETER Identity
    Name, Alias or SamAccountName of the user
.PARAMETER Feature
    MyAnalytics features to enable or disable for the user
.PARAMETER IsEnabled
    Enable or disable the feature specified by the Feature parameter
.PARAMETER PrivacyMode
    Enable or disable MyAnalytics privacy mode for the specified user
.EXAMPLE
    PS> ./Set-EXOMyAnalyticsFeatureConfig.ps1 -Identity "user@domain.com" -Feature "dashboard" -IsEnabled $true
.EXAMPLE
    PS> ./Set-EXOMyAnalyticsFeatureConfig.ps1 -Identity "user@domain.com" -PrivacyMode "opt-in"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [ValidateSet('all','add-in','dashboard','digest-email')]
    [string]$Feature,
    [bool]$IsEnabled,
    [ValidateSet('opt-in','opt-out')]
    [string]$PrivacyMode
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity}

        if ($PSBoundParameters.ContainsKey('Feature')) {
            $cmdArgs.Add('Feature', $Feature)
        }
        if ($PSBoundParameters.ContainsKey('IsEnabled')) {
            $cmdArgs.Add('IsEnabled', $IsEnabled)
        }
        if ($PSBoundParameters.ContainsKey('PrivacyMode')) {
            $cmdArgs.Add('PrivacyMode', $PrivacyMode)
        }
        $null = Set-MyAnalyticsFeatureConfig @cmdArgs

        $result = Get-MyAnalyticsFeatureConfig -Identity $Identity -ErrorAction Stop
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
    }
    catch { throw }
}
