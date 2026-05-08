#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Gets Client Access settings configured on mailboxes
.DESCRIPTION
    Retrieves CAS mailbox settings from Exchange Online using the EXO V2 module. Supports identity-based and ANR-based search with configurable property sets.
.PARAMETER Identity
    Name, Guid or UPN of the mailbox
.PARAMETER AnrSearch
    Partial string for ambiguous name resolution search across CommonName, DisplayName, FirstName, LastName, Alias
.PARAMETER ProtocolSettings
    Returns the server names, TCP ports and encryption methods
.PARAMETER ResultSize
    Maximum number of results to return
.PARAMETER PropertySet
    Logical grouping of properties to retrieve
.PARAMETER Properties
    List of properties to expand. Use * for all properties
.EXAMPLE
    PS> ./Get-EXOCASMailbox.ps1
.EXAMPLE
    PS> ./Get-EXOCASMailbox.ps1 -AnrSearch "john" -ProtocolSettings
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
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
