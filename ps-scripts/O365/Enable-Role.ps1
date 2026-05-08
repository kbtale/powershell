#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Enables a directory role instance
.DESCRIPTION
    Enables an instance of a directory role template, making it available for assignment.
.PARAMETER RoleName
    Display name of the role to enable (from the predefined set of Azure AD roles)
.EXAMPLE
    PS> ./Enable-Role.ps1 -RoleName "Application Administrator"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Application Administrator', 'Application Developer', 'Billing Administrator', 'Cloud Application Administrator',
        'Company Administrator', 'Compliance Administrator', 'Conditional Access Administrator', 'CRM Service Administrator', 'Customer LockBox Access Approver',
        'Device Administrators', 'Device Join', 'Device Managers', 'Device Users', 'Directory Readers', 'Directory Synchronization Accounts', 'Directory Writers',
        'Exchange Service Administrator', 'Guest Inviter', 'Helpdesk Administrator', 'Intune Service Administrator', 'Lync Service Administrator', 'Partner Tier1 Support',
        'Partner Tier2 Support', 'Power BI Service Administrator', 'Privileged Role Administrator', 'Security Administrator', 'Security Reader', 'Service Support Administrator',
        'SharePoint Service Administrator', 'User', 'User Account Administrator', 'Workplace Device Join')]
    [string]$RoleName
)

Process {
    try {
        $roleTemplate = Get-AzureADDirectoryRoleTemplate -ErrorAction Stop | Where-Object { $_.DisplayName -eq $RoleName }

        if ($null -eq $roleTemplate) { throw "Role template '$RoleName' not found" }

        $null = Enable-AzureADDirectoryRole -RoleTemplateId $roleTemplate.ObjectId -ErrorAction Stop

        [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            RoleName  = $RoleName
            Message   = "Role '$RoleName' enabled"
        }
    }
    catch { throw }
}
