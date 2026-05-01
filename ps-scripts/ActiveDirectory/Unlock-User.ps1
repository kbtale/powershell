<#
.SYNOPSIS
	Users: Unlocks an Active Directory account
.DESCRIPTION
	Unlocks a specified Active Directory user account that has been locked out due to too many failed password attempts.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Username
	Display name, SAMAccountName, DistinguishedName or user principal name of the user.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Unlock-User.ps1 -Username "jdoe" -OUPath "OU=Users,DC=contoso,DC=com"
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
		'Properties'  = 'LockedOut'
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }
	$usr = Get-ADUser @getArgs
	
	if ($null -ne $usr) {
		if ($usr.LockedOut) {
			Unlock-ADAccount -Identity $usr.DistinguishedName -Server $Domain.PDCEmulator -AuthType $AuthType -ErrorAction Stop
			Write-Output "User '$Username' unlocked successfully."
		} else {
			Write-Output "User '$Username' is not locked."
		}
	} else {
		throw "User '$Username' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
