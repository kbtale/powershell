<#
.SYNOPSIS
	Users: Resets the password of an Active Directory account
.DESCRIPTION
	Resets the password for a specified Active Directory user account and optionally forces a password change at next logon.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Username
	Display name, SAMAccountName, DistinguishedName or user principal name of the user.
.PARAMETER NewPassword
	The new password for the Active Directory account.
.PARAMETER UserMustChangePasswordAtLogon
	The user must change the password on the next logon.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Reset-UserPassword.ps1 -Username "jdoe" -NewPassword (Read-Host -AsSecureString) -OUPath "OU=Users,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$Username,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[securestring]$NewPassword,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$UserMustChangePasswordAtLogon,

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
		'Filter'      = "SamAccountName -eq '$Username' -or DisplayName -eq '$Username' -or DistinguishedName -eq '$Username' -or UserPrincipalName -eq '$Username'"
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }
	
	$usr = Get-ADUser @getArgs
	
	if ($null -ne $usr) {
		$setArgs = @{
			'ErrorAction' = 'Stop'
			'Server'      = $Domain.PDCEmulator
			'AuthType'    = $AuthType
			'Identity'    = $usr.DistinguishedName
		}
		if ($null -ne $DomainAccount) { $setArgs.Add("Credential", $DomainAccount) }

		Set-ADAccountPassword @setArgs -NewPassword $NewPassword -Reset -Confirm:$false
		Write-Output "Password for user '$($usr.SamAccountName)' has been reset."

		if ($UserMustChangePasswordAtLogon) {
			Set-ADUser @setArgs -PasswordNeverExpires $false -ChangePasswordAtLogon $true -CannotChangePassword $false
			Write-Output "User must change password at next logon."
		}
	} else {
		throw "User '$Username' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
