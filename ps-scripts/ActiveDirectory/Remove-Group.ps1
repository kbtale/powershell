<#
.SYNOPSIS
	Groups: Removes an Active Directory group
.DESCRIPTION
	Deletes a group object from Active Directory.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER GroupName
	DistinguishedName or SamAccountName of the Active Directory group.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Remove-Group.ps1 -GroupName "TemporaryGroup" -OUPath "OU=Groups,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$GroupName,

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

	$getArgs = @{
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
		'Identity'    = $GroupName
	}
	if ($null -ne $DomainAccount) {
		$getArgs.Add("Credential", $DomainAccount)
	}

	$grp = Get-ADGroup @getArgs
	if ($null -ne $grp) {
		$removeArgs = @{
			'ErrorAction' = 'Stop'
			'Server'      = $Domain.PDCEmulator
			'AuthType'    = $AuthType
			'Identity'    = $grp.DistinguishedName
			'Confirm'     = $false
		}
		if ($null -ne $DomainAccount) {
			$removeArgs.Add("Credential", $DomainAccount)
		}
		Remove-ADGroup @removeArgs
		Write-Output "Group '$GroupName' deleted successfully."
	} else {
		throw "Group '$GroupName' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
