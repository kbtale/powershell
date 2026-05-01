<#
.SYNOPSIS
	Users: Gets the properties of an Active Directory account
.DESCRIPTION
	Retrieves the properties of a specified Active Directory user account.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Username
	Display name, SAMAccountName, DistinguishedName or user principal name of the user.
.PARAMETER Properties
	List of properties to expand. Use * for all properties.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-UserProperty.ps1 -Username "jdoe" -OUPath "OU=Users,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$Username,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('*', 'Name', 'GivenName', 'Surname', 'DisplayName', 'DistinguishedName', 'Description', 'Enabled', 'Office', 'EmailAddress', 'OfficePhone', 'Title', 'Department', 'Company', 'StreetAddress', 'PostalCode', 'City', 'SAMAccountName', 'UserPrincipalName', 'MemberOf', 'LastLogonDate', 'LastBadPasswordAttempt', 'AccountExpirationDate', 'CanonicalName')]
	[string[]]$Properties = @('Name', 'GivenName', 'Surname', 'DisplayName', 'Description', 'Office', 'EmailAddress', 'OfficePhone', 'Title', 'Department', 'Company', 'StreetAddress', 'PostalCode', 'City', 'SAMAccountName'),

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$DomainName,

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
		'Filter'      = "SamAccountName -eq '$Username' -or DisplayName -eq '$Username' -or DistinguishedName -eq '$Username' -or UserPrincipalName -eq '$Username'"
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
		'Properties'  = '*'
	}
	if ($null -ne $DomainAccount) {
		$getArgs.Add("Credential", $DomainAccount)
	}

	$usr = Get-ADUser @getArgs
	if ($null -ne $usr) {
		$result = [ordered]@{}
		if ($Properties -eq '*') {
			foreach ($prop in $usr.PropertyNames) {
				$result[$prop] = $usr[$prop]
			}
		} else {
			foreach ($prop in $Properties) {
				$trimmedProp = $prop.Trim()
				$result[$trimmedProp] = $usr[$trimmedProp]
			}
		}
		Write-Output ([PSCustomObject]$result)
	} else {
		throw "User '$Username' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
