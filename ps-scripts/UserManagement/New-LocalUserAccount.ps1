#Requires -Version 5.1

<#
.SYNOPSIS
    User Management: Creates a new local Windows user account
.DESCRIPTION
    Creates a new local Windows user account with password, description, and local group assignments.
.PARAMETER Username
    Username for the new local account
.PARAMETER Password
    Password for the new account
.PARAMETER FullName
    Full name of the user
.PARAMETER Description
    Account description
.PARAMETER LocalGroups
    Local groups to add the user to (e.g., 'Users', 'Administrators', 'Remote Desktop Users')
.PARAMETER PasswordNeverExpires
    Set the password to never expire
.EXAMPLE
    PS> ./New-LocalUserAccount.ps1 -Username "devuser" -Password "P@ssw0rd123!" -FullName "Developer User" -LocalGroups "Users", "Remote Desktop Users" -PasswordNeverExpires
.CATEGORY User Management
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$Password,

    [string]$FullName = '',

    [string]$Description = '',

    [string[]]$LocalGroups = @('Users'),

    [switch]$PasswordNeverExpires
)

Process {
    try {
        if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
            throw "Local user account '$Username' already exists."
        }

        $secPassword = ConvertTo-SecureString $Password -AsPlainText -Force
        
        $userParams = @{
            Name = $Username
            Password = $secPassword
            ErrorAction = 'Stop'
        }
        if ($FullName) { $userParams.Add('FullName', $FullName) }
        if ($Description) { $userParams.Add('Description', $Description) }
        if ($PasswordNeverExpires) { $userParams.Add('PasswordNeverExpires', $true) }

        $user = New-LocalUser @userParams
        
        $addedGroups = @()
        foreach ($groupName in $LocalGroups) {
            try {
                if (Get-LocalGroup -Name $groupName -ErrorAction SilentlyContinue) {
                    Add-LocalGroupMember -Group $groupName -Member $Username -ErrorAction Stop
                    $addedGroups += $groupName
                } else {
                    Write-Warning "Local group '$groupName' was not found. Skipping membership."
                }
            } catch {
                Write-Warning "Failed to add '$Username' to group '$groupName': $_"
            }
        }

        [PSCustomObject]@{
            Username             = $user.Name
            FullName             = $user.FullName
            Enabled              = $user.Enabled
            Description          = $user.Description
            PasswordNeverExpires = $user.PasswordNeverExpires
            LocalGroups          = ($addedGroups -join ', ')
            Created              = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        }
    }
    catch {
        Write-Error $_
        throw
    }
}
