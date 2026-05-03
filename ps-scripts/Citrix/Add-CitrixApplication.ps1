<#
.SYNOPSIS
	Citrix: Adds a Citrix application
.DESCRIPTION
	Registers a new application in the Citrix site.
.PARAMETER Name
	The display name of the application.
.PARAMETER CommandLineExecutable
	The path to the application executable.
.EXAMPLE
	PS> ./Add-CitrixApplication.ps1 -Name "Notepad" -CommandLineExecutable "C:\Windows\notepad.exe"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$CommandLineExecutable
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$app = New-BrokerApplication -Name $Name -CommandLineExecutable $CommandLineExecutable -ErrorAction Stop
	Write-Output $app
} catch {
	Write-Error $_
	exit 1
}