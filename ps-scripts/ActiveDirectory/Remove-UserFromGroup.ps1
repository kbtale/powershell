<#
.SYNOPSIS
	Users: Removes users from Active Directory groups
.DESCRIPTION
	Removes specified user objects from one or more Active Directory groups.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER UserNames
	Comma separated display name, SAMAccountName, DistinguishedName or UPN of the users.
.PARAMETER GroupNames
	Comma separated names or DistinguishedNames of the groups.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Remove-UserFromGroup.ps1 -UserNames "jdoe" -GroupNames "TemporaryProject" -OUPath "OU=Users,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string[]]$UserNames,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string[]]$GroupNames,

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
	
	[string[]]$results = @()
	[string[]]$usrSAMs = @()

	$getArgs = @{
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
	}
	if ($null -ne $DomainAccount) {
		$getArgs.Add("Credential", $DomainAccount)
	}

	# Flatten and process user names
	$flatUsers = foreach ($u in $UserNames) { if ($u -match ',') { $u.Split(',') } else { $u } }
	foreach ($name in $flatUsers) {
		if ([string]::IsNullOrWhiteSpace($name)) { continue }
		try {
			$u = Get-ADUser @getArgs -Filter "SamAccountName -eq '$($name.Trim())' -or DisplayName -eq '$($name.Trim())' -or DistinguishedName -eq '$($name.Trim())' -or UserPrincipalName -eq '$($name.Trim())'" | Select-Object -ExpandProperty SAMAccountName
			$usrSAMs += $u
		} catch {
			$results += "User '$name' not found"
		}
	}

	# Flatten and process group names
	$flatGroups = foreach ($g in $GroupNames) { if ($g -match ',') { $g.Split(',') } else { $g } }
	
	foreach ($usr in $usrSAMs) {
		foreach ($gName in $flatGroups) {
			if ([string]::IsNullOrWhiteSpace($gName)) { continue }
			try {
				$grp = Get-ADGroup @getArgs -Filter "SamAccountName -eq '$($gName.Trim())' -or DistinguishedName -eq '$($gName.Trim())'"
				Remove-ADGroupMember @getArgs -Identity $grp -Members $usr -Confirm:$false
				$results += "User '$usr' removed from Group '$($grp.Name)'"
			} catch {
				$results += "Error removing user '$usr' from Group '$gName': $($_.Exception.Message)"
			}
		}
	}
	
	Write-Output $results
} catch {
	Write-Error $_
	exit 1
}
