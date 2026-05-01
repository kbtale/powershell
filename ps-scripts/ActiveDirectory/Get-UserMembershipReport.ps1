<#
.SYNOPSIS
	Reports: Generates a report with the memberships of an Active Directory user
.DESCRIPTION
	Retrieves a detailed list of all Active Directory groups that the specified user account is a member of.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Username
	Display name, SAMAccountName, DistinguishedName or UPN of the user.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-UserMembershipReport.ps1 -Username "jdoe" -OUPath "OU=Users,DC=contoso,DC=com"
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
		'Properties'  = @('MemberOf')
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }

	$user = Get-ADUser @getArgs
	
	if ($null -ne $user) {
		$groups = $user.MemberOf | ForEach-Object {
			$grpArgs = @{
				'ErrorAction' = 'Stop'
				'Server'      = $Domain.PDCEmulator
				'AuthType'    = $AuthType
				'Identity'    = $_
			}
			if ($null -ne $DomainAccount) { $grpArgs.Add("Credential", $DomainAccount) }
			Get-ADGroup @grpArgs
		} | Select-Object @{n='GroupName';e={$_.Name}}, SAMAccountName, SID, DistinguishedName | Sort-Object GroupName
		
		Write-Output $groups
	} else {
		throw "User '$Username' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
