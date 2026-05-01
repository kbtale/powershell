<#
.SYNOPSIS
	Users: Sets the expiration date for an Active Directory account
.DESCRIPTION
	Updates the account expiration date for a specified Active Directory user account.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Username
	Display name, SAMAccountName, DistinguishedName or UPN of the account.
.PARAMETER ExpirationDate
	Specifies the new expiration date.
.PARAMETER NeverExpires
	Specifies that the account should never expire.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Set-UserExpirationDate.ps1 -Username "jdoe" -ExpirationDate "2026-12-31" -OUPath "OU=Users,DC=contoso,DC=com"
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
	[datetime]$ExpirationDate,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$NeverExpires,

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
		'Filter'      = "SamAccountName -eq '$Username' -or DisplayName -eq '$Username' -or DistinguishedName -eq '$Username' -or UserPrincipalName -eq '$Username'"
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }

	$user = Get-ADUser @getArgs
	
	if ($null -ne $user) {
		$setArgs = @{
			'ErrorAction' = 'Stop'
			'Server'      = $Domain.PDCEmulator
			'AuthType'    = $AuthType
			'Identity'    = $user.SamAccountName
		}
		if ($null -ne $DomainAccount) { $setArgs.Add("Credential", $DomainAccount) }

		if ($NeverExpires) {
			Set-ADUser @setArgs -AccountExpirationDate $null
			Write-Output "Account for user '$Username' set to never expire."
		} else {
			if ($ExpirationDate -lt (Get-Date)) {
				throw "Expiration date cannot be in the past."
			}
			Set-ADUser @setArgs -AccountExpirationDate $ExpirationDate
			Write-Output "Account for user '$Username' expiration date set to $ExpirationDate."
		}
	} else {
		throw "User '$Username' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
