<#
.SYNOPSIS
	Users: Removes an Active Directory account
.DESCRIPTION
	Deletes a user account from Active Directory.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Username
	Display name, SAMAccountName, DistinguishedName or user principal name of the user.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Remove-User.ps1 -Username "jdoe" -OUPath "OU=Users,DC=contoso,DC=com"
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

	$removeArgs = @{
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
		'Identity'    = $Username
		'Confirm'     = $false
	}
	if ($null -ne $DomainAccount) {
		$removeArgs.Add("Credential", $DomainAccount)
	}
	
	Remove-ADUser @removeArgs
	Write-Output "User '$Username' deleted successfully."
} catch {
	Write-Error $_
	exit 1
}
