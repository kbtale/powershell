#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: HTML report of CAS mailbox settings
.DESCRIPTION
    Generates an HTML report of Client Access settings configured on mailboxes using the EXO V2 module.
.PARAMETER Identity
    Name, Guid or UPN of the mailbox
.PARAMETER AnrSearch
    Partial string for ambiguous name resolution search
.PARAMETER ProtocolSettings
    Returns the server names, TCP ports and encryption methods
.PARAMETER ResultSize
    Maximum number of results to return
.PARAMETER PropertySet
    Logical grouping of properties to retrieve
.PARAMETER Properties
    List of properties to expand. Use * for all properties
.EXAMPLE
    PS> ./Get-EXOCASMailbox-Html.ps1 | Out-File report.html
.EXAMPLE
    PS> ./Get-EXOCASMailbox-Html.ps1 -AnrSearch "john" | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(ParameterSetName = 'Default')]
    [string]$Identity,
    [Parameter(Mandatory = $true, ParameterSetName = 'Search')]
    [string]$AnrSearch,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [switch]$ProtocolSettings,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [int]$ResultSize = 1000,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('Minimum','All','ActiveSync','Ews','Imap','Mapi','Pop','ProtocolSettings')]
    [string]$PropertySet = 'Minimum',
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('*','Name','Identity','ActiveSyncEnabled','EwsEnabled','OWAEnabled','PopEnabled','ImapEnabled','MAPIEnabled','ECPEnabled','DisplayName','PrimarySmtpAddress','EmailAddresses','Guid')]
    [string[]]$Properties = @('Name','PrimarySmtpAddress','ActiveSyncEnabled','EwsEnabled','OWAEnabled','PopEnabled','ImapEnabled','MAPIEnabled','ECPEnabled')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }

        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'ResultSize' = $ResultSize; 'PropertySets' = $PropertySet; 'ProtocolSettings' = $ProtocolSettings}

        if ($PSCmdlet.ParameterSetName -eq 'Search') {
            $cmdArgs.Add('Anr', $AnrSearch)
        }
        if (-not [System.String]::IsNullOrWhiteSpace($Identity)) {
            $cmdArgs.Add('Identity', $Identity)
        }

        $result = Get-EXOCasMailbox @cmdArgs | Select-Object $Properties
        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No CAS mailboxes found"
            return
        }

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
