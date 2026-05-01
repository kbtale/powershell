<#
.SYNOPSIS
	Users: Lists users in an Active Directory path
.DESCRIPTION
	Retrieves Active Directory user accounts within a specified OU, with optional filtering by SAM account name.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER SamAccountName
	Filter by SAM account name. Supports wildcards (*). If empty, all users are retrieved.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-User.ps1 -OUPath "OU=Users,DC=contoso,DC=com" -SamAccountName "j*"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true)]
	[string]$OUPath,

	[string]$SamAccountName = "*",

	[PSCredential]$DomainAccount,

	[string]$DomainName,

	[ValidateSet('Base', 'OneLevel', 'SubTree')]
	[string]$SearchScope = 'SubTree',

	[ValidateSet('Basic', 'Negotiate')]
	[string]$AuthType = "Negotiate"
)

try {
	Import-Module ActiveDirectory -ErrorAction Stop

	if ([string]::IsNullOrWhiteSpace($SamAccountName)) {
		$SamAccountName = "*"
	}

	[hashtable]$cmdArgs = @{
		'ErrorAction' = 'Stop'
		'AuthType'    = $AuthType
	}
	if ($null -ne $DomainAccount) {
		$cmdArgs.Add("Credential", $DomainAccount)
	}
	if ([System.String]::IsNullOrWhiteSpace($DomainName)) {
		$cmdArgs.Add("Current", 'LocalComputer')
	} else {
		$cmdArgs.Add("Identity", $DomainName)
	}
	$Domain = Get-ADDomain @cmdArgs

	$getArgs = @{
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
		'Filter'      = "SamAccountName -like '$SamAccountName'"
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
		'Properties'  = @('DistinguishedName', 'DisplayName', 'SamAccountName', 'UserPrincipalName', 'Enabled')
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }

	$users = Get-ADUser @getArgs | Sort-Object DisplayName | Select-Object DisplayName, SamAccountName, UserPrincipalName, Enabled, DistinguishedName

	if ($null -ne $users) {
		Write-Output $users
	} else {
		Write-Output "No users found in OU '$OUPath' matching '$SamAccountName'."
	}
} catch {
	Write-Error $_
	exit 1
}
