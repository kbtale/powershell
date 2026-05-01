<#
.SYNOPSIS
	Users: Returns all users in the same OU as a specified user
.DESCRIPTION
	Identifies the parent OU of a specified "Operator" user and returns all user objects within that OU or below.
.PARAMETER OperatorUsername
	The SAMAccountName of the user whose OU will be searched. Defaults to the current environment user.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-OperatorUser.ps1 -OperatorUsername "jdoe"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $false)]
	[string]$OperatorUsername = $env:USERNAME,

	[Parameter(Mandatory = $false)]
	[PSCredential]$DomainAccount,

	[Parameter(Mandatory = $false)]
	[string]$DomainName,

	[Parameter(Mandatory = $false)]
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
		'Identity'    = $OperatorUsername
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }

	$operator = Get-ADUser @getArgs
	
	if ($null -ne $operator) {
		# Extract parent OU from DistinguishedName
		$dnParts = $operator.DistinguishedName -split ','
		$parentOU = ($dnParts[1..($dnParts.Count - 1)]) -join ','
		
		$searchArgs = @{
			'ErrorAction' = 'Stop'
			'Server'      = $Domain.PDCEmulator
			'AuthType'    = $AuthType
			'Filter'      = "*"
			'SearchBase'  = $parentOU
			'SearchScope' = "Subtree"
		}
		if ($null -ne $DomainAccount) { $searchArgs.Add("Credential", $DomainAccount) }

		$users = Get-ADUser @searchArgs | Sort-Object SamAccountName
		Write-Output $users
	} else {
		throw "Operator user '$OperatorUsername' not found."
	}
} catch {
	Write-Error $_
	exit 1
}
