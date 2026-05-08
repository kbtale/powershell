#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sets sync client restrictions
.DESCRIPTION
    Configures tenant-wide sync client restrictions and options.
.PARAMETER ExcludedFileExtensions
    Blocks certain file types from syncing
.PARAMETER DomainGuids
    Comma-separated domain GUIDs for safe recipient list
.PARAMETER BlockMacSync
    Block Mac sync clients
.PARAMETER Enable
    Enable the sync restriction feature
.PARAMETER GrooveBlockOption
    Controls old OneDrive sync client usage
.PARAMETER DisableReportProblemDialog
    Disable report problem dialog
.EXAMPLE
    PS> ./Set-TenantSyncClientRestriction.ps1 -ExcludedFileExtensions "pst,exe"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = 'FileExclusion')]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'FileExclusion')]
    [string]$ExcludedFileExtensions,
    [Parameter(Mandatory = $true, ParameterSetName = 'Blocking')]
    [string]$DomainGuids,
    [Parameter(Mandatory = $true, ParameterSetName = 'GrooveBlock')]
    [ValidateSet('OptOut','HardOptin','SoftOptin')]
    [string]$GrooveBlockOption,
    [Parameter(Mandatory = $true, ParameterSetName = 'ReportProblem')]
    [bool]$DisableReportProblemDialog,
    [Parameter(ParameterSetName = 'Blocking')]
    [switch]$BlockMacSync,
    [Parameter(ParameterSetName = 'Blocking')]
    [switch]$Enable
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop' }
        if ($PSCmdlet.ParameterSetName -eq 'FileExclusion') { $cmdArgs.Add('ExcludedFileExtensions', $ExcludedFileExtensions) }
        elseif ($PSCmdlet.ParameterSetName -eq 'Blocking') {
            $cmdArgs.Add('BlockMacSync', $BlockMacSync)
            $cmdArgs.Add('Enable', $Enable)
            $guids = $DomainGuids.Split(',')
            $cmdArgs.Add('DomainGuids', $guids)
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'GrooveBlock') { $cmdArgs.Add('GrooveBlockOption', $GrooveBlockOption) }
        elseif ($PSCmdlet.ParameterSetName -eq 'ReportProblem') { $cmdArgs.Add('DisableReportProblemDialog', $DisableReportProblemDialog) }
        $result = Set-SPOTenantSyncClientRestriction @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}