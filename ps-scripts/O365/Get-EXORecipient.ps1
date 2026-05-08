#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Gets recipient objects in the organization
.DESCRIPTION
    Retrieves recipient objects from Exchange Online using the EXO V2 module. Supports identity-based and ANR-based search with extensive filter and property options.
.PARAMETER Identity
    Name, Guid or UPN of the recipient object
.PARAMETER AnrSearch
    Partial string for ambiguous name resolution search across CommonName, DisplayName, FirstName, LastName, Alias
.PARAMETER IncludeSoftDeletedRecipients
    Include soft-deleted recipients in the results
.PARAMETER RecipientType
    Filters results by recipient type
.PARAMETER RecipientTypeDetails
    Filters results by recipient subtype
.PARAMETER ResultSize
    Maximum number of results to return
.PARAMETER PropertySet
    Logical grouping of properties to retrieve
.PARAMETER Properties
    List of properties to expand. Use * for all properties
.EXAMPLE
    PS> ./Get-EXORecipient.ps1
.EXAMPLE
    PS> ./Get-EXORecipient.ps1 -AnrSearch "smith" -RecipientType "UserMailbox"
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
    [switch]$IncludeSoftDeletedRecipients,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('DynamicDistributionGroup','MailContact','MailNonUniversalGroup','MailUniversalDistributionGroup','MailUniversalSecurityGroup','MailUser','PublicFolder','UserMailbox')]
    [string[]]$RecipientType,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('DiscoveryMailbox','DynamicDistributionGroup','EquipmentMailbox','GroupMailbox','GuestMailUser','LegacyMailbox','LinkedMailbox','LinkedRoomMailbox','MailContact','MailForestContact','MailNonUniversalGroup','MailUniversalDistributionGroup','MailUniversalSecurityGroup','MailUser','PublicFolder','PublicFolderMailbox','RemoteEquipmentMailbox','RemoteRoomMailbox','RemoteSharedMailbox','RemoteTeamMailbox','RemoteUserMailbox','RoomList','RoomMailbox','SchedulingMailbox','SharedMailbox','TeamMailbox','UserMailbox')]
    [string[]]$RecipientTypeDetails,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [int]$ResultSize = 1000,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('Minimum','Archive','Custom','MailboxMove','Policy','All')]
    [string]$PropertySet = 'Minimum',
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('*','Name','Identity','FirstName','LastName','City','Company','CountryOrRegion','PostalCode','Department','Office','Alias','DisplayName','DistinguishedName','RecipientType','PrimarySmtpAddress','EmailAddresses','Guid')]
    [string[]]$Properties = @('Name','FirstName','LastName','Identity','Alias','DisplayName','PrimarySmtpAddress')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }

        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'ResultSize' = $ResultSize; 'PropertySets' = $PropertySet; 'IncludeSoftDeletedRecipients' = $IncludeSoftDeletedRecipients}

        if ($PSCmdlet.ParameterSetName -eq 'Search') {
            $cmdArgs.Add('Anr', $AnrSearch)
        }
        if (-not [System.String]::IsNullOrWhiteSpace($Identity)) {
            $cmdArgs.Add('Identity', $Identity)
        }
        if ($PSBoundParameters.ContainsKey('RecipientType')) {
            $cmdArgs.Add('RecipientType', $RecipientType)
        }
        if ($PSBoundParameters.ContainsKey('RecipientTypeDetails')) {
            $cmdArgs.Add('RecipientTypeDetails', $RecipientTypeDetails)
        }

        $result = Get-EXORecipient @cmdArgs | Select-Object $Properties
        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No recipients found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
