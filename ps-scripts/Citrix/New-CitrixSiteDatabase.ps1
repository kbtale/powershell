<#
.SYNOPSIS
	Citrix: Creates a new site database
.DESCRIPTION
	Initializes or configures a new database for the Citrix site.
.PARAMETER DatabaseName
	The name of the database.
.PARAMETER ServerName
	The FQDN of the SQL server.
.EXAMPLE
	PS> ./New-CitrixSiteDatabase.ps1 -DatabaseName "CitrixSite" -ServerName "SQL.contoso.com"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$DatabaseName,

	[Parameter(Mandatory = $true)]
	[string]$ServerName
)

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	$db = New-ConfigSiteDatabase -DatabaseName $DatabaseName -ServerName $ServerName -ErrorAction Stop
	Write-Output $db
} catch {
	Write-Error $_
	exit 1
}