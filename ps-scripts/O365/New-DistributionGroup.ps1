#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Creates a distribution group or mail-enabled security group
.DESCRIPTION
    Creates a new distribution group or mail-enabled security group with optional initial members.
.PARAMETER GroupName
    Unique name of the group (max 64 characters)
.PARAMETER ManagedBy
    Owner identity for the group
.PARAMETER Alias
    Exchange alias for the group
.PARAMETER DisplayName
    Display name of the group
.PARAMETER Description
    Description of the group
.PARAMETER Members
    Recipient identities to add as initial members
.PARAMETER GroupType
    Type of group: Distribution or Security
.EXAMPLE
    PS> ./New-DistributionGroup.ps1 -GroupName "SalesTeam" -ManagedBy "admin@contoso.com" -GroupType Distribution
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [Parameter(Mandatory = $true)]
    [string]$ManagedBy,

    [string]$Alias,
    [string]$DisplayName,
    [string]$Description,
    [string[]]$Members,

    [ValidateSet('Distribution', 'Security')]
    [string]$GroupType = 'Distribution'
)

Process {
    try {
        $results = [System.Collections.ArrayList]::new()

        $grp = New-DistributionGroup -Name $GroupName -Alias $Alias -DisplayName $DisplayName -Note $Description -ManagedBy $ManagedBy -Type $GroupType -Confirm:$false -ErrorAction Stop
        $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Group '$($grp.DisplayName)' created"; ObjectId = $grp.DistinguishedName })

        if ($null -ne $Members) {
            foreach ($member in $Members) {
                try {
                    $null = Add-DistributionGroupMember -Identity $grp.DistinguishedName -Member $member -BypassSecurityGroupManagerCheck -Confirm:$false -ErrorAction Stop
                    $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Member '$member' added" })
                }
                catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Member '$member': $($_.Exception.Message)" }) }
            }
        }

        Write-Output $results
    }
    catch { throw }
}
