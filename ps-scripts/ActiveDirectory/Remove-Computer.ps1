<#
.SYNOPSIS
	Computers: Removes an Active Directory computer
.DESCRIPTION
	Deletes a computer object from Active Directory.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Computername
	DistinguishedName, DNSHostName or SamAccountName of the computer.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Remove-Computer.ps1 -Computername "COMP01" -OUPath "OU=Computers,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$Computername,

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

	$sam = $Computername
	if (-not $sam.EndsWith('$')) {
		$sam += '$'
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
		'AuthType'    = $AuthType
		'Filter'      = "(SamAccountName -eq '$sam') -or (DNSHostName -eq '$Computername') -or (DistinguishedName -eq '$Computername')"
		'Server'      = $Domain.PDCEmulator
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
	}
	if ($null -ne $DomainAccount) {
		$getArgs.Add("Credential", $DomainAccount)
	}
	
	$cmp = Get-ADComputer @getArgs

	if ($null -ne $cmp) {
		$removeArgs = @{
			'ErrorAction' = 'Stop'
			'AuthType'    = $AuthType
			'Identity'    = $cmp
			'Server'      = $Domain.PDCEmulator
			'Confirm'     = $false
		}
		if ($null -ne $DomainAccount) {
			$removeArgs.Add("Credential", $DomainAccount)
		}
		Remove-ADComputer @removeArgs
		Write-Output "Computer '$Computername' deleted successfully."
	} else {
		throw "Computer '$Computername' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
