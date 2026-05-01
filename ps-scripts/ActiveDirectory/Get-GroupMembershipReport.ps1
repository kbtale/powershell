<#
.SYNOPSIS
	Groups: Generates a membership report for an Active Directory group
.DESCRIPTION
	Retrieves the members of a specified Active Directory group, with support for recursive (nested) searching and filtering by object type.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER GroupName
	DistinguishedName or SamAccountName of the Active Directory group.
.PARAMETER Nested
	If specified, recursively retrieves members of nested groups.
.PARAMETER ShowOnlyGroups
	If specified, only includes group objects in the report.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-GroupMembershipReport.ps1 -GroupName "Domain Admins" -Nested -OUPath "DC=contoso,DC=com"
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
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }

	$targetGroup = Get-ADGroup @getArgs -Identity $GroupName -ErrorAction Stop
	
	$results = @()
	$processedGroups = @()

	function Get-MembersInternal($groupDN) {
		if ($processedGroups -contains $groupDN) { return }
		$processedGroups += $groupDN

		$members = Get-ADGroupMember @getArgs -Identity $groupDN
		foreach ($m in $members) {
			if ($m.objectClass -eq "group") {
				$results += [PSCustomObject]@{
					Type              = 'Group'
					Name              = $m.Name
					SamAccountName    = $m.SamAccountName
					DistinguishedName = $m.DistinguishedName
				}
				if ($Nested) {
					Get-MembersInternal $m.DistinguishedName
				}
			} elseif (-not $ShowOnlyGroups) {
				$results += [PSCustomObject]@{
					Type              = $m.objectClass.ToUpper()
					Name              = $m.Name
					SamAccountName    = $m.SamAccountName
					DistinguishedName = $m.DistinguishedName
				}
			}
		}
	}

	Get-MembersInternal $targetGroup.DistinguishedName

	if ($results.Count -gt 0) {
		Write-Output ($results | Sort-Object Type, Name)
	} else {
		Write-Output "No members found in group '$($targetGroup.Name)'."
	}
} catch {
	Write-Error $_
	exit 1
}
