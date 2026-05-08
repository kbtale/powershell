#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Creates a new security group
.DESCRIPTION
    Creates a new security-enabled group in Azure Active Directory. Mail-enabled and security-enabled options are preset.
.PARAMETER GroupName
    Display name of the new group
.PARAMETER Description
    Optional description for the group
.EXAMPLE
    PS> ./New-Group.ps1 -GroupName "Sales Team" -Description "Sales department"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [string]$Description
)

Process {
    try {
        if ([System.String]::IsNullOrEmpty($Description)) {
            $Description = ' '
        }

        $grp = New-AzureADGroup -DisplayName $GroupName -SecurityEnabled $true -Description $Description -MailEnabled $false -MailNickName 'NotSet' -ErrorAction Stop | Select-Object *

        if ($null -ne $grp) {
            [PSCustomObject]@{
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Status      = "Success"
                DisplayName = $grp.DisplayName
                ObjectId    = $grp.ObjectId
                Message     = "Group '$GroupName' created"
            }
        }
        else { throw "Group not created" }
    }
    catch { throw }
}
