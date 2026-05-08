#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Approves a service principal permission grant
.DESCRIPTION
    Approves a permission grant for the tenant's SharePoint Online Client service principal.
.PARAMETER Resource
    Resource of the permission request to approve
.PARAMETER Scope
    Scope of the permission request to approve
.EXAMPLE
    PS> ./Approve-TenantServicePrincipalPermissionGrant.ps1 -Resource "Microsoft.Graph" -Scope "User.Read"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Resource,
    [Parameter(Mandatory = $true)]
    [string]$Scope
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Resource = $Resource; Scope = $Scope }
        $result = Approve-SPOTenantServicePrincipalPermissionGrant @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}