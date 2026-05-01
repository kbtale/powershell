<#
.SYNOPSIS
	Groups: Gets the members of an Active Directory group
.DESCRIPTION
	Retrieves the members of a specified Active Directory group. Supports recursive (nested) membership retrieval and filtering for group objects only.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER GroupName
	DistinguishedName or SamAccountName of the Active Directory group.
.PARAMETER Nested
	Retrieves group members recursively.
.PARAMETER ShowOnlyGroups
	Returns only group objects from the membership list.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-GroupMember.ps1 -GroupName "Domain Admins" -OUPath "DC=contoso,DC=com"
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
	[switch]$Nested,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$ShowOnlyGroups,

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
		'Identity'    = $GroupName
	}
	if ($null -ne $DomainAccount) {
		$getArgs.Add("Credential", $DomainAccount)
	}

	$targetGroup = Get-ADGroup @getArgs
	if ($null -eq $targetGroup) {
		throw "Group '$GroupName' not found."
	}

	function Get-MembersRecursive($groupIdent) {
		$memberArgs = $getArgs.Clone()
		$memberArgs['Identity'] = $groupIdent
		if ($Nested) {
			$memberArgs['Recursive'] = $true
		}
		
		$members = Get-ADGroupMember @memberArgs
		foreach ($m in $members) {
			if ($ShowOnlyGroups -and $m.objectClass -ne "group") {
				continue
			}
			[PSCustomObject]@{
				Type              = $m.objectClass
				Name              = $m.name
				SamAccountName    = $m.SamAccountName
				DistinguishedName = $m.distinguishedName
			}
		}
	}

	$results = Get-MembersRecursive $targetGroup
	if ($null -ne $results) {
		Write-Output $results
	} else {
		Write-Output "No members found in group '$($targetGroup.Name)'."
	}
} catch {
	Write-Error $_
	exit 1
}
