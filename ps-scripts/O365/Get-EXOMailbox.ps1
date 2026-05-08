#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Gets mailbox objects and attributes
.DESCRIPTION
    Retrieves mailbox objects from Exchange Online using the EXO V2 module. Supports identity-based and ANR-based search with extensive filter options.
.PARAMETER Identity
    Name, Guid or UPN of the mailbox
.PARAMETER AnrSearch
    Partial string for ambiguous name resolution search across CommonName, DisplayName, FirstName, LastName, Alias
.PARAMETER Archive
    Returns only mailboxes that have an archive mailbox
.PARAMETER InactiveMailboxOnly
    Returns only inactive mailboxes
.PARAMETER IncludeInactiveMailbox
    Include inactive mailboxes in the results
.PARAMETER SoftDeletedMailbox
    Include soft-deleted mailboxes in the results
.PARAMETER RecipientTypeDetails
    Filters results by mailbox subtype
.PARAMETER ResultSize
    Maximum number of results to return
.PARAMETER PropertySet
    Logical grouping of properties to retrieve
.PARAMETER Properties
    List of properties to expand. Use * for all properties
.EXAMPLE
    PS> ./Get-EXOMailbox.ps1
.EXAMPLE
    PS> ./Get-EXOMailbox.ps1 -AnrSearch "doe" -Archive
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
    [switch]$Archive,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [switch]$InactiveMailboxOnly,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [switch]$IncludeInactiveMailbox,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [switch]$SoftDeletedMailbox,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('DiscoveryMailbox','EquipmentMailbox','GroupMailbox','LegacyMailbox','LinkedMailbox','LinkedRoomMailbox','RoomMailbox','SchedulingMailbox','SharedMailbox','TeamMailbox','UserMailbox')]
    [string[]]$RecipientTypeDetails,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [int]$ResultSize = 1000,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('Minimum','All','AddressList','Archive','Audit','Custom','Hold','Delivery','Moderation','Move','Policy','PublicFolder','Quota','Resource','Retention','SCL','SoftDelete','StatisticsSeed')]
    [string]$PropertySet = 'Minimum',
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('*','Name','Identity','Id','UserPrincipalName','Alias','DisplayName','PrimarySmtpAddress','DistinguishedName','RecipientType','EmailAddresses','Guid')]
    [string[]]$Properties = @('Name','Identity','UserPrincipalName','Alias','DisplayName','PrimarySmtpAddress')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }

        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'ResultSize' = $ResultSize; 'PropertySets' = $PropertySet; 'Archive' = $Archive; 'InactiveMailboxOnly' = $InactiveMailboxOnly; 'IncludeInactiveMailbox' = $IncludeInactiveMailbox; 'SoftDeletedMailbox' = $SoftDeletedMailbox}

        if ($PSCmdlet.ParameterSetName -eq 'Search') {
            $cmdArgs.Add('Anr', $AnrSearch)
        }
        if (-not [System.String]::IsNullOrWhiteSpace($Identity)) {
            $cmdArgs.Add('Identity', $Identity)
        }
        if ($PSBoundParameters.ContainsKey('RecipientTypeDetails')) {
            $cmdArgs.Add('RecipientTypeDetails', $RecipientTypeDetails)
        }

        $result = Get-EXOMailbox @cmdArgs | Select-Object $Properties
        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No mailboxes found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
