<#
.SYNOPSIS
	Common: Moves an Active Directory object to a different container
.DESCRIPTION
	Moves an Active Directory object to a different container.
.PARAMETER TargetOUPath
	Specifies the new location for the object.
.PARAMETER ObjectName
	DistinguishedName or GUID of the Active Directory object. Accepted objects: Group, User, Computer or Service Account.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Move-Object.ps1 -ObjectName "CN=User,OU=Users,DC=contoso,DC=com" -TargetOUPath "OU=NewOU,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$TargetOUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$ObjectName,

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

	$cmdArgs = @{
		'ErrorAction' = 'Stop'
		'AuthType'    = $AuthType
		'TargetPath'  = $TargetOUPath
		'Identity'    = $ObjectName
		'Server'      = $Domain.PDCEmulator
		'Confirm'     = $false
	}
	if ($null -ne $DomainAccount) {
		$cmdArgs.Add("Credential", $DomainAccount)
	}
	
	$res = Move-ADObject @cmdArgs
	Write-Output $res
} catch {
	Write-Error $_
	exit 1
}
