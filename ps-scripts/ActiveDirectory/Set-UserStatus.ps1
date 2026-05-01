<#
.SYNOPSIS
	Users: Enable, disable and/or unlock an Active Directory account
.DESCRIPTION
	Manages the account status of an Active Directory user, allowing enabling, disabling, and unlocking.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Username
	Display name, SAMAccountName, DistinguishedName or user principal name of the user.
.PARAMETER EnableStatus
	Enables or disables the account (Enable, Disable).
.PARAMETER Unlock
	Unlocks the account if it is currently locked out.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Set-UserStatus.ps1 -Username "jdoe" -EnableStatus "Enable" -Unlock -OUPath "OU=Users,DC=contoso,DC=com"
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
	[ValidateSet('Enable', 'Disable')]
	[string]$EnableStatus = 'Enable',

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$Unlock,

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
		'Properties'  = @('LockedOut', 'Enabled')
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }
	$usr = Get-ADUser @getArgs
	
	if ($null -ne $usr) {
		$results = @()
		$setArgs = @{
			'ErrorAction' = 'Stop'
			'Server'      = $Domain.PDCEmulator
			'AuthType'    = $AuthType
			'Identity'    = $usr.DistinguishedName
		}
		if ($null -ne $DomainAccount) { $setArgs.Add("Credential", $DomainAccount) }

		if ($Unlock) {
			if ($usr.LockedOut) {
				Unlock-ADAccount @setArgs
				$results += "User '$Username' unlocked."
			} else {
				$results += "User '$Username' is not locked."
			}
		}

		if ($EnableStatus -eq 'Enable') {
			if (-not $usr.Enabled) {
				Enable-ADAccount @setArgs
				$results += "User '$Username' enabled."
			} else {
				$results += "User '$Username' is already enabled."
			}
		} else {
			if ($usr.Enabled) {
				Disable-ADAccount @setArgs
				$results += "User '$Username' disabled."
			} else {
				$results += "User '$Username' is already disabled."
			}
		}
		
		Write-Output $results
	} else {
		throw "User '$Username' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
