<#
.SYNOPSIS
	Reports: Generates a report with properties of Active Directory accounts
.DESCRIPTION
	Retrieves property information for one or all user objects within a specified Active Directory OU.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Username
	Display name, SAMAccountName, DistinguishedName or user principal name of the account.
.PARAMETER Properties
	List of properties to include in the report. Use * for all properties.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-UserPropertyReport.ps1 -OUPath "OU=Users,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Username,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$DomainName,

	[ValidateSet('*', 'GivenName', 'Surname', 'CN', 'DistinguishedName', 'Description', 'Enabled', 'Office', 'EmailAddress', 'OfficePhone', 'Title', 'Department', 'Company', 'StreetAddress', 'PostalCode', 'City', 'SAMAccountName', 'UserPrincipalName', 'MemberOf', 'LastLogonDate', 'LastBadPasswordAttempt', 'AccountExpirationDate', 'SID')]
	[string[]]$Properties = @('UserPrincipalName', 'CN', 'EmailAddress', 'SID', 'SAMAccountName', 'DistinguishedName'),

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('Base', 'OneLevel', 'SubTree')]
	[string]$SearchScope = 'SubTree',

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('Basic', 'Negotiate')]
	[string]$AuthType = "Negotiate"
)

try {
	Import-Module ActiveDirectory -ErrorAction Stop

	if ($Properties -contains '*') {
		$Properties = @('*')
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
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
		'Properties'  = $Properties
		'Filter'      = '*'
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }

	if (-not [string]::IsNullOrWhiteSpace($Username)) {
		$getArgs['Filter'] = "SamAccountName -eq '$Username' -or DisplayName -eq '$Username' -or DistinguishedName -eq '$Username' -or UserPrincipalName -eq '$Username'"
	}

	$users = Get-ADUser @getArgs | Sort-Object SAMAccountName | Select-Object $Properties
	Write-Output $users
} catch {
	Write-Error $_
	exit 1
}
