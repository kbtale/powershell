<#
.SYNOPSIS
	Computers: Enable or disable an Active Directory computer
.DESCRIPTION
	Enables or disables a computer account in Active Directory.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Computername
	DistinguishedName, DNSHostName or SamAccountName of the computer.
.PARAMETER EnableStatus
	Enables or disables the Active Directory computer (Enable or Disable).
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Set-ComputerStatus.ps1 -Computername "COMP01" -EnableStatus "Disable" -OUPath "OU=Computers,DC=contoso,DC=com"
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
	[ValidateSet('Enable', 'Disable')]
	[string]$EnableStatus = 'Enable',

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
		'Properties'  = 'Enabled,Name'
	}
	if ($null -ne $DomainAccount) {
		$getArgs.Add("Credential", $DomainAccount)
	}

	$cmp = Get-ADComputer @getArgs

	if ($null -ne $cmp) {
		$actionArgs = @{
			'ErrorAction' = 'Stop'
			'AuthType'    = $AuthType
			'Identity'    = $cmp.DistinguishedName
			'Server'      = $Domain.PDCEmulator
		}
		if ($null -ne $DomainAccount) {
			$actionArgs.Add("Credential", $DomainAccount)
		}
	
		if ($EnableStatus -eq 'Enable') {
			if ($cmp.Enabled -eq $false) {
				Enable-ADAccount @actionArgs
				Write-Output "Computer '$($cmp.Name)' enabled."
			} else {
				Write-Output "Computer '$($cmp.Name)' is already enabled."
			}
		} else {
			if ($cmp.Enabled -eq $true) {
				Disable-ADAccount @actionArgs
				Write-Output "Computer '$($cmp.Name)' disabled."
			} else {
				Write-Output "Computer '$($cmp.Name)' is already disabled."
			}
		}
	} else {
		throw "Computer '$Computername' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
